import SwiftUI

/// Maya's listening state uses the same ear, leaf, and glasses as the app icon.
struct MayaPresenceView: View {
    enum Mode: Equatable { case idle, listening, thinking, speaking }

    var mode: Mode = .idle
    var size: CGFloat = 250

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.ivory)
                .overlay {
                    Circle()
                        .strokeBorder(Theme.teal.opacity(mode == .idle ? 0.14 : 0.45),
                                      lineWidth: mode == .idle ? 1 : 3)
                }

            Image("MayaMark")
                .resizable()
                .scaledToFit()
                .padding(size * 0.055)
                .scaleEffect(reduceMotion ? 1 : symbolScale)
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: mode)
        .accessibilityHidden(true)
    }

    private var symbolScale: CGFloat {
        switch mode {
        case .idle: return 1
        case .listening: return 0.94
        case .thinking: return 0.98
        case .speaking: return 1.04
        }
    }
}

#Preview {
    ZStack {
        Theme.bg.ignoresSafeArea()
        MayaPresenceView(mode: .listening)
    }
}
