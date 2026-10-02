import SwiftUI

@main
struct InovitecApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

enum Theme {
    static let darkGreen = Color(red: 0.12, green: 0.40, blue: 0.27)
    static let headerGreen = Color(red: 0.55, green: 0.72, blue: 0.60)
    static let mineralsBlue = Color(red: 0.80, green: 0.92, blue: 0.96)
    static let drinkPink = Color(red: 0.98, green: 0.85, blue: 0.86)
    static let heatPurple = Color(red: 0.86, green: 0.86, blue: 0.96)
    static let background = Color(red: 0.92, green: 0.92, blue: 0.92)
}
