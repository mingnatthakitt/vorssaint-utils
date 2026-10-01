// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import AVFoundation
import CoreImage
import ScreenCaptureKit

/// The production service runs with deterministic native-picker, capture and
/// network doubles. These tests never request permissions or send private media.
enum GeminiLiveLifecycleTests {
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
                  let input = envelope["realtimeInput"] as? [String: Any],
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
        service.screenOutput?.onFrame(Data([2]))
        service.screenOutput?.onFrame(Data([3]))
        await drain()
        // Startup's first frame stays in flight; a burst retains only its latest successor.
        suite.expect(first.videos.count <= 1, "screen sends stay bounded while the transport is busy")
        first.completeSend()
        await drain()
        suite.expect(first.videos.last == Data([3]),
                     "the last changed frame is eventually delivered even if the screen then stays idle")
        let captured = service.stream!
        service.stop()
        await drain()
        suite.expect(service.state == .idle && first.cancelled && captured.stopped && picker.observers.isEmpty,
                     "stop releases capture, transport and picker observation")
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
        for socket in URLSession.sockets { while !socket.completions.isEmpty { socket.completeSend() } }
        await drain()
        URLSession.sockets = []
    }
}
