// OpenVision - VoiceAgentView.swift
// Main voice conversation UI in Maya's warm palette.
//
// MVVM: this view only renders state and forwards interactions — every piece of orchestration
// (session lifecycle, command routing, live video, TTS streaming) lives in VoiceAgentViewModel.

import SwiftUI

struct VoiceAgentView: View {
    // MARK: - Environment

    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var glassesManager: GlassesManager
    @ObservedObject private var mayaShortcutRouter = MayaShortcutRouter.shared

    // MARK: - ViewModel

    @StateObject private var viewModel = VoiceAgentViewModel()

    // MARK: - Observed services
    // Only the services whose @Published state the body reacts to directly. They are the same
    // singletons the ViewModel drives — observed here purely so onChange fires.

    @StateObject private var voiceCommandService = VoiceCommandService.shared
    @StateObject private var ttsService = TTSService.shared
    @StateObject private var kokoroTTS = KokoroTTSService.shared
    @StateObject private var documentFocus = DocumentFocus.shared

    // MARK: - Body

    var body: some View {
        ZStack {
            AnimatedBackground()

            // Main content — the orb stays vertically centered and STABLE. The transcript is a
            // separate overlay (below) so it can never push the orb around.
            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)
                // Document-focus pill: visible whenever a document is "open" so the mode is never
                // silently steering answers. Tap to release focus.
                if let doc = documentFocus.activeDocument {
                    Button {
                        documentFocus.deactivate()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "book.fill").font(.caption2)
                            Text(doc.title).font(.caption.bold()).lineLimit(1)
                            Image(systemName: "xmark.circle.fill").font(.caption2).opacity(0.7)
                        }
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .background(Theme.bgElevated, in: Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
                }
                Spacer()
                centerContent
                Spacer()
            }

            // Transcript floats over the bottom; growing text stays inside its own card and doesn't
            // move the orb.
            if settingsManager.settings.showTranscripts
                && (!viewModel.userTranscript.isEmpty || !viewModel.aiTranscript.isEmpty || viewModel.agentState == .thinking) {
                VStack {
                    Spacer()
                    transcriptArea
                        .padding(.bottom, 28)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Error overlay
            if let error = viewModel.errorMessage {
                errorOverlay(error)
            }
        }
        // Animate the state text and the transcript's appear/disappear only — NOT every streamed
        // token (the old .spring on userTranscript/aiTranscript sprang the whole view and jostled
        // the orb on every word).
        .animation(.easeInOut(duration: 0.3), value: viewModel.agentState)
        .animation(.easeInOut(duration: 0.35), value: viewModel.userTranscript.isEmpty)
        .animation(.easeInOut(duration: 0.35), value: viewModel.aiTranscript.isEmpty)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .onChange(of: mayaShortcutRouter.voiceRouteID) {
            viewModel.onAppear()
        }
        .task {
            await viewModel.requestSpeechAuthorization()
        }
        // Observe TTS state changes
        .onChange(of: ttsService.isSpeaking) { _, isSpeaking in
            viewModel.ttsSpeakingChanged(isSpeaking)
        }
        .onChange(of: kokoroTTS.isSpeaking) { _, speaking in
            viewModel.kokoroSpeakingChanged(speaking)
        }
        // Control thinking sound based on agent state
        .onChange(of: viewModel.agentState) { _, newState in
            viewModel.agentStateChanged(newState)
        }
        // Observe VoiceCommandService state changes
        .onChange(of: voiceCommandService.state) { _, newState in
            viewModel.voiceStateChanged(newState)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // AI Backend status (or Live Video indicator)
            if viewModel.isLiveVideoMode {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(.red.opacity(0.5), lineWidth: 2)
                                .scaleEffect(1.5)
                        )

                    Text("LIVE")
                        .font(.caption.bold())
                        .foregroundColor(.white)

                    Image(systemName: "video.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.red.opacity(0.8))
                )
            } else {
                StatusPill(
                    status: settingsManager.settings.backendDisplayName,
                    color: viewModel.agentState == .idle ? Theme.textSecondary : Theme.accent,
                    isConnected: viewModel.agentState != .idle && viewModel.agentState != .connecting
                )
            }

            Spacer()

            // Transient "Saved to Photos" / failure status after a recording finishes.
            if let status = viewModel.recordingStatus {
                Text(status)
                    .font(.caption.bold())
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.bgElevated, in: Capsule())
                    .transition(.opacity)
            }

            // POV recording toggle (glasses video + as-heard audio → Photos).
            if glassesManager.isRegistered {
                Button {
                    viewModel.toggleRecording()
                } label: {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.title2)
                        .foregroundStyle(viewModel.isRecording ? .red : Theme.textPrimary)
                        .padding(.horizontal, 4)
                }
                .accessibilityLabel(viewModel.isRecording ? "Stop recording" : "Record point of view")
            }

            // Glasses status
            HStack(spacing: 8) {
                Image(systemName: "eyeglasses")
                    .foregroundStyle(glassesManager.isRegistered ? Theme.accent : Theme.textSecondary)

                if glassesManager.isStreaming {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.bgElevated, in: Capsule())
        }
        .padding(.horizontal)
    }

    // MARK: - Center Content

    /// Map the agent state to Maya's visual mode.
    private var presenceMode: MayaPresenceView.Mode {
        switch viewModel.agentState {
        case .listening: return .listening
        case .speaking: return .speaking
        case .thinking, .toolRunning, .connecting: return .thinking
        case .idle, .liveVideo: return .idle
        }
    }

    private var centerContent: some View {
        VStack(spacing: 28) {
            // Heading / status prompt
            Group {
                if viewModel.agentState == .liveVideo {
                    VStack(spacing: 6) {
                        Text(settingsManager.settings.backendDisplayName)
                            .font(.headline)
                            .foregroundColor(Theme.heading)
                        Text("Say \"stop video\" to exit")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                } else if viewModel.agentState == .idle && settingsManager.settings.wakeWordEnabled {
                    VStack(spacing: 8) {
                        Text("What can I see?")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.heading)
                        if viewModel.isVoiceReady {
                            Text("Say \"\(settingsManager.settings.wakeWord)\" or tap Maya")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        } else {
                            HStack(spacing: 8) {
                                ProgressView().tint(Theme.accent).scaleEffect(0.8)
                                Text("Initializing voice…")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                }
            }
            .transition(.opacity)

            Button {
                viewModel.toggleSession()
            } label: {
                MayaPresenceView(mode: presenceMode, size: 250)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.agentState == .idle ? "Start talking to Maya" : "Stop talking to Maya")

            // Status text
            Text(viewModel.agentState.displayText)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimary)

            // Tool status
            if let tool = viewModel.currentToolName, viewModel.agentState == .toolRunning {
                ToolStatusView(toolName: tool, isRunning: true)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Transcript Area

    // Bubbles float directly over the background (no outer card box — the old GlassCard wrapper
    // was a mostly-empty gray slab).
    private var transcriptArea: some View {
        TranscriptView(
            userText: viewModel.userTranscript,
            aiText: viewModel.aiTranscript,
            isAIStreaming: viewModel.agentState == .speaking
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Error Overlay

    private func errorOverlay(_ message: String) -> some View {
        VStack {
            Spacer()

            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    viewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            .padding(.bottom, 150)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    VoiceAgentView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(GlassesManager.shared)
}
