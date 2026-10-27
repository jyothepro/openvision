import SwiftUI

/// Content cards are solid and legible; the system supplies glass for navigation and controls.
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20

    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background(Theme.bgElevated, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Theme.bgElevatedStroke)
            }
    }
}

struct StatusPill: View {
    let status: String
    let color: Color
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(Theme.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.bgElevated, in: Capsule())
        .overlay { Capsule().strokeBorder(Theme.bgElevatedStroke) }
        .accessibilityLabel("\(status), \(isConnected ? "connected" : "not connected")")
    }
}
