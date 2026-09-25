// OpenVision - MainTabView.swift
// Main tab navigation: Voice Agent, History, Settings

import SwiftUI

struct MainTabView: View {
    // MARK: - Environment

    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var glassesManager: GlassesManager
    @EnvironmentObject var conversationManager: ConversationManager
    @ObservedObject private var mayaShortcutRouter = MayaShortcutRouter.shared

    // MARK: - State

    @State private var selectedTab: Tab = .voice

    // MARK: - Tab Enum

    enum Tab: String, CaseIterable {
        case voice = "Voice"
        case history = "History"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .voice: return "waveform.circle.fill"
            case .history: return "clock.fill"
            case .settings: return "gearshape.fill"
            }
        }

    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUI.Tab(Tab.voice.rawValue, systemImage: Tab.voice.icon, value: Tab.voice) {
                VoiceAgentView()
            }
            SwiftUI.Tab(Tab.history.rawValue, systemImage: Tab.history.icon, value: Tab.history) {
                ConversationListView()
            }
            SwiftUI.Tab(Tab.settings.rawValue, systemImage: Tab.settings.icon, value: Tab.settings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
        .onChange(of: mayaShortcutRouter.voiceRouteID) {
            selectedTab = .voice
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(GlassesManager.shared)
        .environmentObject(ConversationManager.shared)
}
