// OpenVision - TranscriptBubble.swift
// Maya transcript bubbles: user = teal (right), Maya = warm surface (left).
// Bubbles float directly over the background — no outer card box.

import SwiftUI

/// Animated typing indicator.
struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 7, height: 7)
                    .opacity(animating ? 1.0 : 0.25)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Theme.bgElevated)
                .overlay(Capsule().stroke(Theme.bgElevatedStroke, lineWidth: 1))
        )
        .onAppear { animating = true }
    }
}

/// One transcript bubble. The text renders live (the token stream already animates it) —
/// no artificial per-character typing effect.
struct TranscriptBubble: View {
    let text: String
    let isUser: Bool
    let isStreaming: Bool

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 5) {
                Text(isUser ? "You" : "Maya")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(text)
                    .font(.callout)
                    .foregroundStyle(isUser ? Color.white : Theme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
            }

            if !isUser { Spacer(minLength: 48) }
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.teal)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.bgElevatedStroke, lineWidth: 1)
                )
        }
    }
}

/// The conversation transcript: user bubble, then the AI reply. Long replies scroll inside a
/// bounded area and auto-follow the newest text while streaming.
struct TranscriptView: View {
    let userText: String
    let aiText: String
    let isAIStreaming: Bool

    var body: some View {
        VStack(spacing: 10) {
            if !userText.isEmpty {
                TranscriptBubble(text: userText, isUser: true, isStreaming: false)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            if !aiText.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        TranscriptBubble(text: aiText, isUser: false, isStreaming: isAIStreaming)
                            .id("reply")
                    }
                    .frame(maxHeight: 190)
                    .fixedSize(horizontal: false, vertical: aiFitsWithoutScrolling)
                    .onChange(of: aiText) {
                        // Follow the newest text as it streams in.
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo("reply", anchor: .bottom)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            } else if isAIStreaming {
                HStack {
                    TypingIndicator()
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        // Animate bubble appear/disappear only — not every streamed token.
        .animation(.easeInOut(duration: 0.3), value: userText.isEmpty)
        .animation(.easeInOut(duration: 0.3), value: aiText.isEmpty)
    }

    /// Short replies size to content (no dead space); long ones cap at maxHeight and scroll.
    private var aiFitsWithoutScrolling: Bool { aiText.count < 220 }
}

/// Tool status indicator
struct ToolStatusView: View {
    let toolName: String
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.subheadline)
                .foregroundColor(Theme.accent)

            Text(toolName)
                .font(.subheadline)
                .fontWeight(.medium)

            if isRunning {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(Theme.accent)
            }
        }
        .foregroundColor(Theme.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bgElevated, in: Capsule())
    }
}

#Preview {
    ZStack {
        Theme.bg.ignoresSafeArea()

        VStack(spacing: 24) {
            TranscriptView(
                userText: "Hi Maya, what's the weather like today?",
                aiText: "Based on your location, it's currently 72°F and sunny. Perfect weather for being outside!",
                isAIStreaming: false
            )

            TypingIndicator()

            ToolStatusView(toolName: "weather_lookup", isRunning: true)
        }
        .padding()
    }
}
