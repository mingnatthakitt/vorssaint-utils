// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import AVFoundation
import CoreImage
import ScreenCaptureKit

/// The production service runs with deterministic native-picker, capture and
/// network doubles. These tests never request permissions or send private media.
enum GeminiLiveLifecycleTests {
    enum AVCaptureDevice {
        static func requestAccess(for mediaType: AVMediaType) async -> Bool { true }
    }
    final class AVAudioEngine {
        static var instances: [AVAudioEngine] = []
        static var rejectVoiceProcessing = false
        lazy var inputNode = Input(engine: self)
        let mainMixerNode = NSObject()
        var isRunning = false
        init() { Self.instances.append(self) }
        func attach(_ node: AVAudioPlayerNode) {}
        func connect(_ node: AVAudioPlayerNode, to mixer: NSObject, format: AVAudioFormat) {}
        func start() throws { isRunning = true }
        func stop() { isRunning = false }
        final class Input {
            weak var engine: AVAudioEngine?
            var isVoiceProcessingEnabled = false
            var isVoiceProcessingInputMuted = false
            var tap: AVAudioNodeTapBlock?
            init(engine: AVAudioEngine) { self.engine = engine }
            func setVoiceProcessingEnabled(_ enabled: Bool) throws {
                guard engine?.isRunning == false, !AVAudioEngine.rejectVoiceProcessing else { throw CancellationError() }
                isVoiceProcessingEnabled = enabled
            }
            func outputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat {
                AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!
            }
            func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat,
                            block: @escaping AVAudioNodeTapBlock) { tap = block }
            func removeTap(onBus bus: AVAudioNodeBus) { tap = nil }
        }
    }
    final class AVAudioPlayerNode {
        var isPlaying = false
        var completions: [(AVAudioPlayerNodeCompletionCallbackType) -> Void] = []
        func scheduleBuffer(_ buffer: AVAudioPCMBuffer, completionCallbackType: AVAudioPlayerNodeCompletionCallbackType,
                            completionHandler: @escaping (AVAudioPlayerNodeCompletionCallbackType) -> Void) {
            completions.append(completionHandler)
        }
        func play() { isPlaying = true }
        func stop() { isPlaying = false }
        func reset() {}
    }
    enum AppFeature {
        case geminiLive
        var isAvailable: Bool { true }
    }
    protocol SCContentSharingPickerObserver: AnyObject {
        func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?)
        func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?)
        func contentSharingPickerStartDidFailWithError(_ error: Error)
    }
    final class SCContentSharingPicker {
        static let shared = SCContentSharingPicker()
        var defaultConfiguration = SCContentSharingPickerConfiguration()
        var isActive = false
        var observers: [SCContentSharingPickerObserver] = []
        func add(_ observer: SCContentSharingPickerObserver) { observers.append(observer) }
        func remove(_ observer: SCContentSharingPickerObserver) { observers.removeAll { $0 === observer } }
        func present() {}
    }
    final class SCContentFilter { let contentRect = CGRect(x: 0, y: 0, width: 128, height: 128) }
    protocol SCStreamDelegate {
        func stream(_ stream: SCStream, didStopWithError error: Error)
    }
    protocol SCStreamOutput {
        func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType)
    }
    final class SCStream {
        var output: GeminiLiveScreenOutput?
        var stopped = false
        init(filter: SCContentFilter, configuration: SCStreamConfiguration, delegate: SCStreamDelegate) {}
        func addStreamOutput(_ output: GeminiLiveScreenOutput, type: SCStreamOutputType, sampleHandlerQueue: DispatchQueue) throws {
            self.output = output
        }
        func startCapture() async throws {
            // A static screen produces one complete frame before startup returns.
            output?.onFrame(Data([1]))
            for _ in 0..<10 { await Task.yield() }
        }
        func stopCapture() async throws { stopped = true }
    }
    @MainActor final class URLSession {
        static var sockets: [URLSessionWebSocketTask] = []
        init(configuration: URLSessionConfiguration) {}
        func webSocketTask(with url: URL) -> URLSessionWebSocketTask {
            let socket = URLSessionWebSocketTask()
            Self.sockets.append(socket)
            return socket
        }
        func invalidateAndCancel() {}
    }
    @MainActor final class URLSessionWebSocketTask {
        enum Message { case data(Data), string(String) }
        enum CloseCode { case normalClosure }
        var videos: [Data] = []
        var audio: [Data] = []
        var audioStreamEnds = 0
        var completions: [CheckedContinuation<Void, Error>] = []
        var waiting: CheckedContinuation<Message, Error>?
        var ready = false
        var cancelled = false
        func resume() {}
        func cancel(with code: CloseCode, reason: Data?) {
            cancelled = true
            waiting?.resume(throwing: CancellationError())
            waiting = nil
        }
        func send(_ message: Message) async throws {
            guard case .data(let bytes) = message,
                  let envelope = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                  let input = envelope["realtimeInput"] as? [String: Any] else { return }
            if input["audioStreamEnd"] as? Bool == true { audioStreamEnds += 1 }
            if let blob = input["audio"] as? [String: String], let data = Data(base64Encoded: blob["data"] ?? "") {
                audio.append(data)
                return
            }
            guard
                  let video = input["video"] as? [String: String],
                  let data = Data(base64Encoded: video["data"] ?? "") else { return }
            videos.append(data)
            try await withCheckedThrowingContinuation { completions.append($0) }
        }
        func receive() async throws -> Message {
            if !ready {
                ready = true
                return .data(Data(#"{"setupComplete":{}}"#.utf8))
            }
            if cancelled { throw CancellationError() }
            return try await withCheckedThrowingContinuation { waiting = $0 }
        }
        func completeSend() { if !completions.isEmpty { completions.removeFirst().resume() } }
        func deliver(_ envelope: [String: Any]) throws {
            let receiver = waiting
            waiting = nil
            receiver?.resume(returning: .data(try JSONSerialization.data(withJSONObject: envelope)))
        }
    }

    static func run(_ suite: TestSuite) {
        var finished = false
        Task { @MainActor in
            await checks(suite)
            finished = true
        }
        let deadline = Date().addingTimeInterval(10)
        while !finished && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.005))
        }
        suite.expect(finished, "Gemini lifecycle checks finish without native permissions or network access")
    }

    @MainActor static func drain() async { for _ in 0..<100 { await Task.yield() } }

    @MainActor static func checks(_ suite: TestSuite) async {
        let picker = SCContentSharingPicker.shared
        let service = GeminiLiveService()
        func select() {
            picker.observers.last?.contentSharingPicker(picker, didUpdateWith: SCContentFilter(), for: nil)
        }
        service.start(apiKey: "synthetic-test-key")
        select()
        await drain()
        let first = URLSession.sockets.last!
        suite.expect(service.state == .live && first.videos == [Data([1])],
                     "the initial static-screen frame survives capture startup")
        suite.expect(AVAudioEngine.instances.isEmpty,
                     "starting screen sharing alone does not activate an audio input engine")
        service.screenOutput?.onFrame(Data([2]))
        service.screenOutput?.onFrame(Data([3]))
        await drain()
        // Startup's first frame stays in flight; a burst retains only its latest successor.
        suite.expect(first.videos.count <= 1, "screen sends stay bounded while the transport is busy")
        first.completeSend()
        await drain()
        suite.expect(first.videos.last == Data([3]),
                     "the last changed frame is eventually delivered even if the screen then stays idle")
        await interruptionChecks(service, socket: first, suite: suite)
        let captured = service.stream!
        service.stop()
        await drain()
        suite.expect(service.state == .idle && first.cancelled && captured.stopped && picker.observers.isEmpty,
                     "stop releases capture, transport and picker observation")
        suite.expect(AVAudioEngine.instances.allSatisfy { !$0.isRunning && $0.inputNode.tap == nil },
                     "stopping the session releases the shared audio engine and microphone tap")
        service.start(apiKey: "synthetic-test-key")
        select()
        await drain()
        let second = URLSession.sockets.last!
        service.screenOutput?.onFrame(Data([4]))
        await drain()
        first.completeSend()
        await drain()
        suite.expect(second.videos == [Data([1])], "old send completion cannot flush a new session's pending frame")
        second.completeSend()
        await drain()
        suite.expect(second.videos == [Data([1]), Data([4])], "the current session still flushes its own latest frame")
        service.stop()
        second.completeSend()
        await drain()

        for callback in 0..<3 {
            service.start(apiKey: "synthetic-test-key")
            let previous = picker.observers.last!
            // Queue the callback first, then restart before its actor task runs.
            switch callback {
            case 0: previous.contentSharingPicker(picker, didCancelFor: nil)
            case 1: previous.contentSharingPicker(picker, didUpdateWith: SCContentFilter(), for: nil)
            default: previous.contentSharingPickerStartDidFailWithError(CancellationError())
            }
            service.stop()
            service.start(apiKey: "synthetic-test-key")
            await drain()
            suite.expect(service.state == .selecting && service.error == nil,
                         "queued picker callback \(callback) cannot affect a restarted attempt")
            service.stop()
        }
        service.start(apiKey: "synthetic-test-key")
        picker.observers.last?.contentSharingPicker(picker, didCancelFor: nil)
        await drain()
        suite.expect(service.state == .idle, "cancelling the current picker still ends selection")
        service.start(apiKey: "synthetic-test-key")
        picker.observers.last?.contentSharingPickerStartDidFailWithError(CancellationError())
        await drain()
        suite.expect(service.state == .idle && service.error != nil, "a current picker failure still reports an error")
        service.stop()
        service.start(apiKey: "synthetic-test-key")
        select()
        await drain()
        AVAudioEngine.rejectVoiceProcessing = true
        service.toggleMicrophone()
        await drain()
        suite.expect(service.state == .idle && service.isMuted && service.error != nil
                     && AVAudioEngine.instances.allSatisfy { !$0.isRunning && $0.inputNode.tap == nil },
                     "unavailable echo cancellation fails safely without sending untreated microphone audio")
        AVAudioEngine.rejectVoiceProcessing = false
        for socket in URLSession.sockets { while !socket.completions.isEmpty { socket.completeSend() } }
        await drain()
        URLSession.sockets = []
        AVAudioEngine.instances = []
    }

    @MainActor static func interruptionChecks(_ service: GeminiLiveService, socket: URLSessionWebSocketTask, suite: TestSuite) async {
        let speech = Data(repeating: 0, count: 12000)
        let speaking: [String: Any] = ["serverContent": ["modelTurn": ["parts": [[
            "inlineData": ["mimeType": "audio/pcm;rate=24000", "data": speech.base64EncodedString()]
        ]]]]]
        try! socket.deliver(speaking)
        await drain()
        suite.expect(service.playbackFrames == 6000 && service.player?.isPlaying == true,
                     "server speech starts local playback before microphone activation")
        let oldCompletion = service.player!.completions.last!
        service.toggleMicrophone()
        await drain()
        let engine = AVAudioEngine.instances.last!
        suite.expect(!service.isMuted && engine.inputNode.isVoiceProcessingEnabled && AVAudioEngine.instances.count == 1,
                     "microphone and assistant playback share an echo-cancelled engine")
        let buffer = AVAudioPCMBuffer(pcmFormat: engine.inputNode.outputFormat(forBus: 0), frameCapacity: 2048)!
        buffer.frameLength = 2048
        for index in 0..<2048 { buffer.floatChannelData!.pointee[index] = 0.25 }
        let time = AVAudioTime(sampleTime: 0, atRate: 48000)
        let tap = engine.inputNode.tap!
        tap(buffer, time)
        await drain()
        suite.expect(!socket.audio.isEmpty && service.playbackFrames > 0,
                     "microphone PCM reaches Gemini while assistant speech is still queued")
        let audioCount = socket.audio.count
        try! socket.deliver(["serverContent": ["interrupted": true, "modelTurn": ["parts": [[
            "inlineData": ["mimeType": "audio/pcm;rate=24000", "data": speech.base64EncodedString()]
        ]]]]])
        await drain()
        suite.expect(service.playbackFrames == 0 && service.player?.isPlaying == false && !service.isMuted,
                     "an interruption clears queued speech immediately and keeps the microphone listening")
        try! socket.deliver(speaking)
        await drain()
        oldCompletion(.dataPlayedBack)
        await drain()
        suite.expect(service.playbackFrames == 6000 && service.player?.isPlaying == true,
                     "late completion of interrupted speech cannot consume the next reply")
        service.toggleMicrophone()
        tap(buffer, time)
        await drain()
        suite.expect(service.isMuted && socket.audio.count == audioCount && socket.audioStreamEnds == 1,
                     "muting stops microphone delivery and tells Gemini the audio stream ended")
        suite.expect(engine.isRunning && engine.inputNode.isVoiceProcessingInputMuted && engine.inputNode.tap == nil,
                     "muting silences processed input and removes its tap without stopping assistant playback")
        service.toggleMicrophone()
        await drain()
        tap(buffer, time)
        await drain()
        suite.expect(socket.audio.count == audioCount,
                     "a delayed callback from before mute cannot leak into a newly unmuted microphone")
        engine.inputNode.tap?(buffer, time)
        await drain()
        suite.expect(socket.audio.count == audioCount + 1 && !engine.inputNode.isVoiceProcessingInputMuted,
                     "the new microphone tap resumes delivery during the next reply")
    }
}
