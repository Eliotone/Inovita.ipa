import SwiftUI

struct RootView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showPanel = false
    @State private var showMap = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .trailing) {
            HomeView(showPanel: $showPanel, showMap: $showMap)
                .disabled(showPanel)

            if showPanel {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { closePanel() }
                    .transition(.opacity)

                SidePanelView(isDarkMode: $isDarkMode, onClose: closePanel, onSettings: {
                    closePanel()
                    showSettings = true
                })
                .transition(.move(edge: .trailing))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $showMap) { LocationView() }
        .sheet(isPresented: $showSettings) { SettingsView(isDarkMode: $isDarkMode) }
    }

    private func closePanel() {
        withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
    }
}

// MARK: - Home

struct HomeView: View {
    @Binding var showPanel: Bool
    @Binding var showMap: Bool
    @State private var showMinerals = false
    @State private var showDrink = false
    @State private var showHeating = false
    @State private var showProfile = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 18) {
                    topCards
                    Spacer(minLength: 50)
                    centerMessage
                    Spacer(minLength: 24)
                }
                .padding(.top, 18)
            }

            bottomBar
        }
        .background(Theme.background)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showMinerals) { PlaceholderDetail(title: "Minéraux") }
        .sheet(isPresented: $showDrink) { PlaceholderDetail(title: "Hydratation") }
        .sheet(isPresented: $showHeating) { PlaceholderDetail(title: "Mode Chauffage") }
        .sheet(isPresented: $showProfile) { PlaceholderDetail(title: "Profil utilisateur") }
    }

    private var header: some View {
        HStack {
            Button { showProfile = true } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.3)).frame(width: 38, height: 38)
                        Image(systemName: "person.fill").foregroundStyle(.white)
                    }
                    Text("Utilisateur").font(.title3.weight(.semibold)).foregroundStyle(.white)
                }
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = true }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 58)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
        .background(
            Theme.headerGradient
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
    }

    private var topCards: some View {
        HStack(alignment: .top, spacing: 14) {
            Button { showMinerals = true } label: { MineralsCard() }
                .buttonStyle(CardButtonStyle())

            VStack(spacing: 14) {
                Button { showDrink = true } label: {
                    InfoCard(icon: "waterbottle.fill", iconColor: Theme.roseBar, gradient: Theme.drinkGradient,
                             title: "Restant à boire", value: "389ml", progress: 0.45, progressColor: Theme.roseBar)
                }.buttonStyle(CardButtonStyle())

                Button { showHeating = true } label: {
                    InfoCard(icon: "thermometer.medium", iconColor: Theme.cyanInk, gradient: Theme.heatGradient,
                             title: "Mode Chauffage", value: "21°C", progress: nil, progressColor: .clear)
                }.buttonStyle(CardButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }

    private var centerMessage: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Rectangle().fill(Theme.accent.opacity(0.4)).frame(width: 70, height: 1.5)
                ZStack {
                    Circle().fill(Theme.headerGradient).frame(width: 82, height: 82)
                        .shadow(color: Theme.accent.opacity(0.4), radius: 10, y: 4)
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                Rectangle().fill(Theme.accent.opacity(0.4)).frame(width: 70, height: 1.5)
            }
            Text("Prenez soin de vous")
                .font(.title3.bold())
                .foregroundStyle(Theme.accent)
            Text("Votre santé est notre priorité")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button {} label: {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill").font(.title3)
                    Text("Accueil").font(.caption2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            }

            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 1, height: 30)

            Button { showMap = true } label: {
                VStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse").font(.title3)
                    Text("Localisation").font(.caption2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 14)
        .background(Theme.barGradient, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
        .padding(.top, 8)
    }
}

// MARK: - Cards

struct MineralsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(Theme.titleInk)
                Text("Minéraux").font(.headline).foregroundStyle(Theme.titleInk)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            HStack(alignment: .bottom, spacing: 14) {
                MineralBar(name: "Fer", value: 0.35, colors: [Theme.roseBar, Theme.roseBar])
                MineralBar(name: "Zinc", value: 0.65, colors: [Theme.lime, Theme.lime])
                MineralBar(name: "Calcium", value: 0.55, colors: [Theme.sun, Theme.sun])
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.mineralsGradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

struct MineralBar: View {
    let name: String
    let value: CGFloat
    let colors: [Color]

    var body: some View {
        VStack(spacing: 8) {
            // Name ABOVE the slider
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Capsule().fill(Color.white.opacity(0.85))
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
                        .frame(height: geo.size.height * value)
                }
            }
            .frame(width: 20, height: 80)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let gradient: LinearGradient
    let title: String
    let value: String
    let progress: CGFloat?
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundStyle(iconColor)
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            Text(value).font(.title2.bold()).foregroundStyle(.primary)
            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.6))
                        Capsule().fill(progressColor).frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(gradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Side panel

struct SidePanelView: View {
    @Binding var isDarkMode: Bool
    let onClose: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Menu").font(.title2.bold()).foregroundStyle(.white)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").foregroundStyle(.white)
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(Theme.headerGradient)

            // Dark / light switch
            HStack(spacing: 14) {
                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .foregroundStyle(isDarkMode ? Color.indigo : Color.orange)
                    .frame(width: 24)
                Text(isDarkMode ? "Mode sombre" : "Mode clair")
                Spacer()
                Toggle("", isOn: $isDarkMode).labelsHidden().tint(Theme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider()

            row(icon: "gearshape.fill", color: .teal, title: "Paramètres", action: onSettings)
            row(icon: "person.crop.circle.fill", color: .blue, title: "Mon profil", action: onClose)
            row(icon: "bell.fill", color: .orange, title: "Notifications", action: onClose)
            row(icon: "questionmark.circle.fill", color: .purple, title: "Aide", action: onClose)

            Spacer()
        }
        .frame(width: 270)
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }

    private func row(icon: String, color: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).foregroundStyle(color).frame(width: 24)
                Text(title).foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
}

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Apparence") {
                    Toggle(isOn: $isDarkMode) { Label("Mode sombre", systemImage: "moon.fill") }
                        .tint(Theme.accent)
                }
                Section("Compte") {
                    Label("Modifier le profil", systemImage: "person.fill")
                    Label("Changer le mot de passe", systemImage: "lock.fill")
                }
                Section("Appareils") {
                    Label("Appareils connectés", systemImage: "antenna.radiowaves.left.and.right")
                    Label("Bluetooth", systemImage: "dot.radiowaves.left.and.right")
                }
                Section("Application") {
                    Label("Notifications", systemImage: "bell.fill")
                    Label("Langue", systemImage: "globe")
                    Label("À propos", systemImage: "info.circle.fill")
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } }
            }
        }
    }
}

struct PlaceholderDetail: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hourglass").font(.system(size: 44)).foregroundStyle(Theme.accent)
                Text("Bientôt disponible").font(.title3.bold())
                Text("Les détails de \"\(title)\" arrivent dans une prochaine mise à jour.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Rounded corner helper

struct RoundedCorner: Shape {
    var radius: CGFloat = 20
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
