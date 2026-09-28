import SwiftUI

@main
struct InovitaApp: App {
    @StateObject private var ble = BluetoothManager()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(ble).tint(Theme.accent)
        }
    }
}

enum Theme {
    static let accent = Color(red: 0.05, green: 0.6, blue: 0.55)
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            GPSView()
                .tabItem { Label("GPS", systemImage: "location.fill") }
        }
    }
}

struct GPSView: View {
    var body: some View {
        NavigationStack {
            Color.clear.navigationTitle("GPS")
        }
    }
}
