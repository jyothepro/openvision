import SwiftUI

/// A quiet content backdrop derived from the two leaf shapes in the Maya mark.
struct AnimatedBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.bg

                Ellipse()
                    .fill(Theme.leaf.opacity(0.11))
                    .frame(width: geometry.size.width * 0.9,
                           height: geometry.size.height * 0.44)
                    .rotationEffect(.degrees(-30))
                    .position(x: geometry.size.width * 0.93,
                              y: geometry.size.height * 0.27)

                Ellipse()
                    .fill(Theme.teal.opacity(0.055))
                    .frame(width: geometry.size.width * 0.76,
                           height: geometry.size.height * 0.34)
                    .rotationEffect(.degrees(28))
                    .position(x: geometry.size.width * 0.04,
                              y: geometry.size.height * 0.83)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview {
    AnimatedBackground()
}
