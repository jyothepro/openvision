import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 16) {
                TabView(selection: $currentPage) {
                    welcome.tag(0)
                    features.tag(1)
                    setup.tag(2)
                    ready.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Theme.teal : Theme.teal.opacity(0.18))
                            .frame(width: currentPage == index ? 25 : 8, height: 8)
                    }
                }
                .accessibilityLabel("Page \(currentPage + 1) of 4")

                HStack {
                    if currentPage > 0 {
                        Button("Back") { withAnimation { currentPage -= 1 } }
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Button(currentPage == 3 ? "Get Started" : "Next") {
                        withAnimation {
                            if currentPage == 3 {
                                hasCompletedOnboarding = true
                            } else {
                                currentPage += 1
                            }
                        }
                    }
                    .mayaPrimaryAction()
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
    }

    private var welcome: some View {
        page {
            Image("MayaMark")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .padding(18)
                .background(Theme.ivory, in: Circle())
                .accessibilityHidden(true)

            Text("Meet Maya")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            Text("See more of your world, hands-free.")
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var features: some View {
        page {
            Text("Made for the moment")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: 12) {
                feature("Ask out loud", icon: "waveform", detail: "Talk to Maya while your hands stay free.")
                feature("Look closer", icon: "eyeglasses", detail: "Ask about what your glasses see.")
                feature("Keep things moving", icon: "checkmark.circle", detail: "Set reminders, search, and get help on the go.")
                feature("Choose your privacy", icon: "lock.shield", detail: "Pick a cloud or on-device assistant.")
            }
        }
    }

    private var setup: some View {
        page {
            Text("A few quick steps")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            VStack(alignment: .leading, spacing: 18) {
                step(1, "Choose an assistant", "Set up your preferred backend in Settings.")
                step(2, "Connect your glasses", "Register them when you're ready.")
                step(3, "Say “Hi Maya”", "Start a conversation or tap Maya.")
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.bgElevated, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private var ready: some View {
        page {
            Image(systemName: "checkmark")
                .font(.system(size: 62, weight: .semibold))
                .foregroundStyle(Theme.teal)
                .frame(width: 138, height: 138)
                .background(Theme.leaf.opacity(0.28), in: Circle())

            Text("You're ready")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            Text("Set up your assistant and glasses in Settings, then ask Maya what you see.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func page<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 12)
                    content()
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
    }

    private func feature(_ title: String, icon: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.teal)
                .frame(width: 46, height: 46)
                .background(Theme.leaf.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
                Text(detail).font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Theme.bgElevated, in: RoundedRectangle(cornerRadius: 20))
    }

    private func step(_ number: Int, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Theme.teal, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
                Text(detail).font(.subheadline).foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
