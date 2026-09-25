// OpenVision - SettingsView.swift
// Main settings menu with navigation to configuration panels

import SwiftUI

struct SettingsView: View {
    // MARK: - Environment

    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var glassesManager: GlassesManager

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image("MayaMark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 54)
                            .padding(5)
                            .background(Theme.ivory, in: RoundedRectangle(cornerRadius: 15))
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Maya")
                                .font(.title3.bold())
                                .foregroundStyle(Theme.textPrimary)
                            Text("Your glasses companion")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 5)
                }

                // AI Backend Section
                Section {
                    NavigationLink {
                        AIBackendSettingsView()
                    } label: {
                        HStack {
                            Label("AI Backend", systemImage: "cpu")
                            Spacer()
                            Text(settingsManager.settings.aiBackend.displayName)
                                .foregroundColor(.secondary)
                            if !settingsManager.settings.isCurrentBackendConfigured {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    NavigationLink {
                        WebSearchSettingsView()
                    } label: {
                        HStack {
                            Label("Web Search", systemImage: "magnifyingglass")
                            Spacer()
                            Text(settingsManager.settings.tavilyAPIKey.isEmpty ? "DuckDuckGo" : "Tavily")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Only show for Gemini Live (OpenClaw has its own system prompt & memories)
                    if settingsManager.settings.aiBackend == .geminiLive {
                        NavigationLink {
                            AdditionalInstructionsView()
                        } label: {
                            Label("Custom Instructions", systemImage: "text.quote")
                        }

                        NavigationLink {
                            MemoriesView()
                        } label: {
                            HStack {
                                Label("Memories", systemImage: "brain")
                                Spacer()
                                Text("\(settingsManager.settings.memories.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("AI")
                }

                // Hardware Section
                Section {
                    NavigationLink {
                        GlassesSettingsView()
                    } label: {
                        HStack {
                            Label("Glasses", systemImage: "eyeglasses")
                            Spacer()
                            if glassesManager.isRegistered {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                } header: {
                    Text("Hardware")
                }

                // Voice Section
                Section {
                    NavigationLink {
                        VoiceSettingsView()
                    } label: {
                        HStack {
                            Label("Voice Control", systemImage: "mic.fill")
                            Spacer()
                            if settingsManager.settings.wakeWordEnabled {
                                Text(settingsManager.settings.wakeWord)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Off")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Voice")
                }

                // Advanced Section
                Section {
                    NavigationLink {
                        DocumentsSettingsView()
                    } label: {
                        Label("My Documents", systemImage: "books.vertical")
                    }

                    NavigationLink {
                        TelemetrySettingsView()
                    } label: {
                        Label("Telemetry", systemImage: "chart.line.uptrend.xyaxis")
                    }

                    Toggle(isOn: $settingsManager.settings.autoReconnect) {
                        Label("Auto-Reconnect", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Toggle(isOn: $settingsManager.settings.showTranscripts) {
                        Label("Show Transcripts", systemImage: "text.bubble")
                    }
                } header: {
                    Text("Advanced")
                }

                // About Section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("\(Config.appVersion) (\(Config.buildNumber))")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/rayl15/OpenVision")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }

                    Link(destination: URL(string: "https://github.com/openclaw/openclaw")!) {
                        Label("Get OpenClaw", systemImage: "arrow.up.right.square")
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("OpenVision is open source under the MIT license.")
                }
            }
            .mayaFormSurface()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(GlassesManager.shared)
}
