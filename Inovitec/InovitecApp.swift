import SwiftUI

@main
struct InovitecApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

extension Color {
    init(light: Color, dark: Color) {
        self = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

enum Theme {
    // Palette
    static let sage       = Color(hex: 0x8fb79d)
    static let sageSoft   = Color(hex: 0xc5dccb)
    static let forest     = Color(hex: 0x1b6e3f)
    static let forestDark = Color(hex: 0x14502e)
    static let page       = Color(hex: 0xdedede)
    static let ink        = Color(hex: 0x111111)
    static let cyan       = Color(hex: 0xc9f1fb)
    static let cyanInk    = Color(hex: 0x0b3d8f)
    static let rose       = Color(hex: 0xfdd2d2)
    static let roseBar    = Color(hex: 0xf48b8b)
    static let lilac      = Color(hex: 0xdadcf6)
    static let lime       = Color(hex: 0xc9f56b)
    static let sun        = Color(hex: 0xfbd85d)

    // Adaptive (light / dark)
    static let background = Color(light: page, dark: Color(hex: 0x101416))
    static let accent     = Color(light: forest, dark: sage)
    static let titleInk   = Color(light: cyanInk, dark: Color(hex: 0x9cc2ff))

    static func flat(_ light: Color, _ dark: Color) -> LinearGradient {
        let c = Color(light: light, dark: dark)
        return LinearGradient(colors: [c, c], startPoint: .top, endPoint: .bottom)
    }

    static let headerGradient   = flat(sage, Color(hex: 0x2b4a38))
    static let barGradient      = LinearGradient(
        colors: [Color(light: forest, dark: Color(hex: 0x1e4d33)),
                 Color(light: forestDark, dark: Color(hex: 0x163a26))],
        startPoint: .top, endPoint: .bottom)
    static let mineralsGradient = flat(cyan, Color(hex: 0x16414d))
    static let drinkGradient    = flat(rose, Color(hex: 0x4d2a2c))
    static let heatGradient     = flat(lilac, Color(hex: 0x2c2e55))
}
