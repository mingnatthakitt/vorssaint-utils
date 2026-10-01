// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

struct GeminiLiveView: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var features = FeatureRuntime.shared
    @ObservedObject private var service = GeminiLiveService.shared
    @State private var key = ""
    @State private var keyError: String?
    private var strings: GeminiLiveStrings { FeatureStrings.geminiLive(l10n.language) }

    var body: some View {
        Form {
            Section {
                Text(strings.description)
                Text(strings.privacy).font(.caption).foregroundStyle(.secondary)
            } header: { Text(strings.title) }
            Section {
                SecureField(strings.keyLabel, text: $key)
                    .disabled(service.state != .idle)
                HStack {
                    Button(strings.save) { saveKey(key) }
                        .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || service.state != .idle)
                    Button(strings.remove, role: .destructive) { saveKey("") }
                        .disabled(service.state != .idle)
                    Link(strings.getKey, destination: URL(string: "https://aistudio.google.com/apikey")!)
                }
                if let keyError { Text(keyError).foregroundStyle(.red) }
            } header: { Text(strings.keyLabel) }
            Section {
                HStack {
                    if service.state == .idle {
                        Button(strings.share) { service.start(apiKey: key) }
                            .disabled(!AppFeature.geminiLive.isAvailable)
                    } else {
                        Button(strings.stop, role: .destructive) { service.stop() }
                        if service.state == .live {
                            Button(service.isMuted ? strings.unmute : strings.mute) { service.toggleMicrophone() }
                                .disabled(service.microphoneRequestPending)
                        } else {
                            ProgressView().controlSize(.small)
                            Text(strings.connecting)
                        }
                    }
                }
                if service.state == .live {
                    Label(strings.active, systemImage: "record.circle.fill").foregroundStyle(.red)
                }
                if let error = service.error { Text(error).foregroundStyle(.red) }
                if !service.inputText.isEmpty { Label(service.inputText, systemImage: "mic") }
                if !service.outputText.isEmpty { Label(service.outputText, systemImage: "sparkles").textSelection(.enabled) }
            }
        }
        .formStyle(.grouped)
        .task {
            guard AppFeature.geminiLive.isAvailable else { return }
            do { key = try GeminiLiveKeyStore.load() }
            catch { keyError = strings.keychainFailed }
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.willSleepNotification)) { _ in
            service.stop()
        }
        .onReceive(DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.screenIsLocked"))) { _ in
            service.stop()
        }
        .onDisappear { service.stop(); key = "" }
    }

    private func saveKey(_ value: String) {
        guard AppFeature.geminiLive.isAvailable else { return }
        do {
            try GeminiLiveKeyStore.save(value)
            key = value.trimmingCharacters(in: .whitespacesAndNewlines)
            keyError = nil
        } catch { keyError = strings.keychainFailed }
    }
}
