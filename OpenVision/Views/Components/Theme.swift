// Maya's colors come from the Listening Glasses icon. Content stays warm and readable;
// system controls supply the platform's glass treatment on supported iOS releases.

import SwiftUI
import UIKit

enum Theme {
    static let teal = Color(red: 20 / 255, green: 106 / 255, blue: 102 / 255)
    static let leaf = Color(red: 164 / 255, green: 201 / 255, blue: 79 / 255)
    static let charcoal = Color(red: 36 / 255, green: 52 / 255, blue: 67 / 255)
    static let ivory = Color(red: 1, green: 244 / 255, blue: 221 / 255)

    static let accent = adaptive(light: UIColor(red: 20 / 255, green: 106 / 255, blue: 102 / 255, alpha: 1),
                                 dark: UIColor(red: 137 / 255, green: 213 / 255, blue: 179 / 255, alpha: 1))
    static let bg = adaptive(light: UIColor(red: 1, green: 244 / 255, blue: 221 / 255, alpha: 1),
                             dark: UIColor(red: 19 / 255, green: 34 / 255, blue: 35 / 255, alpha: 1))
    static let bgElevated = adaptive(light: UIColor(red: 1, green: 250 / 255, blue: 240 / 255, alpha: 1),
                                     dark: UIColor(red: 31 / 255, green: 53 / 255, blue: 51 / 255, alpha: 1))
    static let bgElevatedStroke = adaptive(light: UIColor(red: 20 / 255, green: 106 / 255, blue: 102 / 255, alpha: 0.14),
                                           dark: UIColor(red: 194 / 255, green: 229 / 255, blue: 205 / 255, alpha: 0.16))
    static let textPrimary = adaptive(light: UIColor(red: 36 / 255, green: 52 / 255, blue: 67 / 255, alpha: 1),
                                      dark: UIColor(red: 248 / 255, green: 246 / 255, blue: 234 / 255, alpha: 1))
    static let textSecondary = adaptive(light: UIColor(red: 78 / 255, green: 94 / 255, blue: 99 / 255, alpha: 1),
                                        dark: UIColor(red: 188 / 255, green: 205 / 255, blue: 194 / 255, alpha: 1))
    static let heading = accent

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

extension View {
    func mayaFormSurface() -> some View {
        scrollContentBackground(.hidden)
            .background(Theme.bg)
    }

    @ViewBuilder
    func mayaPrimaryAction() -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.glassProminent)
                .tint(Theme.teal)
        } else {
            buttonStyle(.borderedProminent)
                .tint(Theme.teal)
        }
    }
}
