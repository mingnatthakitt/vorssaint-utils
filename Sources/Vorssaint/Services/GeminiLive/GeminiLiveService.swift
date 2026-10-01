// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import AVFoundation
import Combine
import CoreImage
import ScreenCaptureKit

/// Only exists when its settings page is opened. No capture or network work at rest.
@MainActor
final class GeminiLiveService: NSObject, ObservableObject {
    static let shared = GeminiLiveService()
    enum State { case idle, selecting, connecting, live }
    @Published private(set) var state = State.idle
    @Published private(set) var isMuted = true
    @Published private(set) var inputText = ""
    @Published private(set) var outputText = ""
    @Published private(set) var error: String?

    private var socket: URLSessionWebSocketTask?
    private var network: URLSession?
    private var connectionTask: Task<Void, Never>?
    private var timeoutTask: Task<Void, Never>?
    private var generation = UUID()
    private var apiKey = ""
    private var stream: SCStream?
    private var screenOutput: GeminiLiveScreenOutput?
    private var captureEngine: AVAudioEngine?
    private var playbackEngine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var playbackGeneration = UUID()
    private var playbackFrames = 0
    private var audioPending = false
    private var videoPending = false
    @Published private(set) var microphoneRequestPending = false
    private var pickerActive = false

    private var strings: GeminiLiveStrings { FeatureStrings.geminiLive(L10n.shared.language) }

    func start(apiKey: String) {
        guard AppFeature.geminiLive.isAvailable, state == .idle else { return }
        guard GeminiLiveSupport.endpoint(apiKey: apiKey) != nil else {
            error = strings.keyRequired
            return
        }
        error = nil
        inputText = ""
        outputText = ""
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        state = .selecting
        generation = UUID()
        let picker = SCContentSharingPicker.shared
        var config = SCContentSharingPickerConfiguration()
        config.allowedPickerModes = [.singleWindow, .singleDisplay]
        config.allowsChangingSelectedContent = false
        picker.defaultConfiguration = config
        picker.add(self)
        picker.isActive = true
        pickerActive = true
        picker.present()
    }

    func stop() {
        generation = UUID()
        state = .idle
        isMuted = true
        microphoneRequestPending = false
        inputText = ""
        outputText = ""
        apiKey = ""
        timeoutTask?.cancel()
        timeoutTask = nil
        connectionTask?.cancel()
        connectionTask = nil
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
        network?.invalidateAndCancel()
        network = nil
        stopMicrophone()
        clearPlayback()
        playbackEngine?.stop()
        playbackEngine = nil
        player = nil
        if let stream {
            self.stream = nil
            Task { try? await stream.stopCapture() }
        }
        screenOutput = nil
        audioPending = false
        videoPending = false
        if pickerActive {
            SCContentSharingPicker.shared.remove(self)
            SCContentSharingPicker.shared.isActive = false
            pickerActive = false
        }
    }

    func toggleMicrophone() {
        guard AppFeature.geminiLive.isAvailable, state == .live, !microphoneRequestPending else { return }
        if !isMuted {
            isMuted = true
            stopMicrophone()
            send(["realtimeInput": ["audioStreamEnd": true]])
            return
        }
        let id = generation
        microphoneRequestPending = true
        Task {
            let allowed = await AVCaptureDevice.requestAccess(for: .audio)
            guard id == generation, state == .live, AppFeature.geminiLive.isAvailable else { return }
            microphoneRequestPending = false
            guard allowed else { error = strings.microphoneDenied; return }
            do {
                try startMicrophone()
                isMuted = false
            } catch {
                stopMicrophone()
                self.error = strings.audioFailed
            }
        }
    }

    private func connect(filter: SCContentFilter) {
        guard state == .selecting, AppFeature.geminiLive.isAvailable,
              let url = GeminiLiveSupport.endpoint(apiKey: apiKey) else { stop(); return }
        state = .connecting
        let id = generation
        let session = URLSession(configuration: .ephemeral)
        network = session
        let socket = session.webSocketTask(with: url)
        self.socket = socket
        apiKey = ""
        socket.resume()
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard !Task.isCancelled, let self, self.generation == id, self.state == .connecting else { return }
            self.fail(self.strings.connectionFailed)
        }
        connectionTask = Task { [weak self] in
            do {
                let setup = try JSONSerialization.data(withJSONObject: GeminiLiveSupport.setup)
                try await socket.send(.data(setup))
                while !Task.isCancelled {
                    let message = try await socket.receive()
                    guard let self, self.generation == id, AppFeature.geminiLive.isAvailable else { return }
                    let data: Data
                    switch message {
                    case .data(let bytes): data = bytes
                    case .string(let text): data = Data(text.utf8)
                    @unknown default: continue
                    }
                    let event = try GeminiLiveSupport.decode(data)
                    if event.failed { self.fail(self.strings.connectionFailed); return }
                    if event.ended { self.fail(self.strings.sessionEnded); return }
                    if event.ready, self.state == .connecting {
                        try await self.startCapture(filter: filter, id: id)
                        guard self.generation == id else { return }
                        self.timeoutTask?.cancel()
                        self.state = .live
                    }
                    if event.interrupted { self.clearPlayback() }
                    if let text = event.inputText { self.inputText = String((self.inputText + text).suffix(4000)) }
                    if let text = event.outputText { self.outputText = String((self.outputText + text).suffix(8000)) }
                    do {
                        for audio in event.audio { try self.play(audio) }
                    } catch { self.fail(self.strings.audioFailed); return }
                }
            } catch {
                guard let self, self.generation == id else { return }
                // Never display raw networking errors: they can contain the credential URL.
                self.fail(self.strings.connectionFailed)
            }
        }
    }

    private func fail(_ message: String) {
        stop()
        error = message
    }

    private func send(_ message: [String: Any], video: Bool? = nil) {
        guard AppFeature.geminiLive.isAvailable, state == .live, let socket else { return }
        if video == true { guard !videoPending else { return }; videoPending = true }
        if video == false { guard !audioPending else { return }; audioPending = true }
        let id = generation
        Task { [weak self] in
            do {
                let data = try JSONSerialization.data(withJSONObject: message)
                try await socket.send(.data(data))
                guard let self, self.generation == id else { return }
                if video == true { self.videoPending = false }
                if video == false { self.audioPending = false }
            } catch {
                guard let self, self.generation == id else { return }
                self.fail(self.strings.connectionFailed)
            }
        }
    }

    private func startCapture(filter: SCContentFilter, id: UUID) async throws {
        let config = SCStreamConfiguration()
        let rect = filter.contentRect
        let scale = min(1, 1280 / max(rect.width, rect.height, 1))
        config.width = max(2, Int(rect.width * scale))
        config.height = max(2, Int(rect.height * scale))
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
        config.queueDepth = 2
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.showsCursor = true
        config.capturesAudio = false
        let output = GeminiLiveScreenOutput { [weak self] data in
            Task { @MainActor in
                guard let self, self.generation == id else { return }
                self.send(GeminiLiveSupport.realtime(data, video: true), video: true)
            }
        }
        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: output.queue)
        self.stream = stream
        screenOutput = output
        try await stream.startCapture()
        if generation != id { try? await stream.stopCapture() }
    }

    private func startMicrophone() throws {
        let engine = AVAudioEngine()
        let input = engine.inputNode
        let hardware = input.outputFormat(forBus: 0)
        guard hardware.sampleRate > 0, hardware.channelCount > 0,
              let target = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true),
              let converter = AVAudioConverter(from: hardware, to: target) else { throw CocoaError(.coderInvalidValue) }
        let id = generation
        input.installTap(onBus: 0, bufferSize: 2048, format: hardware) { [weak self] buffer, _ in
            let capacity = AVAudioFrameCount(Double(buffer.frameLength) * 16000 / hardware.sampleRate) + 64
            guard let converted = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: capacity) else { return }
            var consumed = false
            var error: NSError?
            converter.convert(to: converted, error: &error) { _, status in
                if consumed { status.pointee = .noDataNow; return nil }
                consumed = true
                status.pointee = .haveData
                return buffer
            }
            guard error == nil, converted.frameLength > 0, let samples = converted.int16ChannelData else { return }
            let data = Data(bytes: samples.pointee, count: Int(converted.frameLength) * 2)
            Task { @MainActor in
                guard let self, self.generation == id, !self.isMuted,
                      self.playbackFrames == 0 else { return }
                self.send(GeminiLiveSupport.realtime(data, video: false), video: false)
            }
        }
        captureEngine = engine
        try engine.start()
    }

    private func stopMicrophone() {
        if let engine = captureEngine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        captureEngine = nil
    }

    private func clearPlayback() {
        playbackGeneration = UUID()
        playbackFrames = 0
        player?.stop()
        player?.reset()
    }

    private func play(_ data: Data) throws {
        guard data.count.isMultiple(of: 2), let format = AVAudioFormat(standardFormatWithSampleRate: 24000, channels: 1) else { return }
        if playbackEngine == nil {
            let engine = AVAudioEngine()
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            try engine.start()
            playbackEngine = engine
            player = node
        }
        let frames = data.count / 2
        // Bound queued speech even if playback falls behind the network.
        guard playbackFrames + frames <= 24000 * 30,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)),
              let samples = buffer.floatChannelData?.pointee else { return }
        buffer.frameLength = AVAudioFrameCount(frames)
        data.withUnsafeBytes { bytes in
            for index in 0..<frames {
                let low = UInt16(bytes[index * 2])
                let high = UInt16(bytes[index * 2 + 1]) << 8
                samples[index] = Float(Int16(bitPattern: low | high)) / 32768
            }
        }
        playbackFrames += frames
        let id = playbackGeneration
        player?.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.playbackGeneration == id else { return }
                self.playbackFrames = max(0, self.playbackFrames - frames)
            }
        }
        player?.play()
    }
}

extension GeminiLiveService: SCContentSharingPickerObserver, SCStreamDelegate {
    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?) {
        Task { @MainActor in if self.state == .selecting { self.stop() } }
    }

    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?) {
        Task { @MainActor in self.connect(filter: filter) }
    }

    nonisolated func contentSharingPickerStartDidFailWithError(_ error: Error) {
        Task { @MainActor in self.fail(self.strings.captureFailed) }
    }

    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        Task { @MainActor in
            guard self.stream === stream else { return }
            self.fail(self.strings.captureFailed)
        }
    }
}

private final class GeminiLiveScreenOutput: NSObject, SCStreamOutput {
    let queue = DispatchQueue(label: "com.vorssaint.gemini-live.screen", qos: .utility)
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let onFrame: (Data) -> Void
    private var lastFrame = Date.distantPast

    init(onFrame: @escaping (Data) -> Void) { self.onFrame = onFrame }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, sampleBuffer.isValid,
              let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
              let status = attachments.first?[.status] as? Int,
              status == SCFrameStatus.complete.rawValue,
              Date().timeIntervalSince(lastFrame) >= 0.9,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lastFrame = Date()
        autoreleasepool {
            guard let jpeg = context.jpegRepresentation(of: CIImage(cvPixelBuffer: pixelBuffer), colorSpace: colorSpace,
                options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.65]) else { return }
            onFrame(jpeg)
        }
    }
}
