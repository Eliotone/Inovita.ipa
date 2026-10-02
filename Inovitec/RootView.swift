import SwiftUI

struct RootView: View {
    @State private var showPanel = false
    @State private var showLocationAlert = false
    @State private var showSettingsPanel = false

    var body: some View {
        ZStack(alignment: .trailing) {
            HomeView(showPanel: $showPanel, showLocationAlert: $showLocationAlert)
                .disabled(showPanel)

            if showPanel {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { showPanel = false } }
                    .transition(.opacity)

                SidePanelView(showPanel: $showPanel, showSettingsPanel: $showSettingsPanel)
                    .transition(.move(edge: .trailing))
            }
        }
        .alert("Service indisponible", isPresented: $showLocationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("La localisation n'est pas encore disponible. Cette fonctionnalité arrive bientôt.")
        }
        .sheet(isPresented: $showSettingsPanel) {
            SettingsView()
        }
    }
}

// MARK: - Home

struct HomeView: View {
    @Binding var showPanel: Bool
    @Binding var showLocationAlert: Bool
    @State private var showMineralsDetail = false
    @State private var showDrinkDetail = false
    @State private var showHeatingDetail = false
    @State private var showProfile = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 18) {
                    topCards
                    Spacer(minLength: 60)
                    centerMessage
                    Spacer(minLength: 24)
                }
                .padding(.top, 18)
            }
            .background(Theme.background)

            bottomBar
        }
        .background(Theme.background)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showMineralsDetail) { PlaceholderDetail(title: "Minéraux") }
        .sheet(isPresented: $showDrinkDetail) { PlaceholderDetail(title: "Hydratation") }
        .sheet(isPresented: $showHeatingDetail) { PlaceholderDetail(title: "Mode Chauffage") }
        .sheet(isPresented: $showProfile) { PlaceholderDetail(title: "Profil utilisateur") }
    }

    private var header: some View {
        HStack {
            Button { showProfile = true } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.35)).frame(width: 36, height: 36)
                        Image(systemName: "person.fill").foregroundStyle(.white)
                    }
                    Text("Utilisateur").font(.title3.weight(.medium)).foregroundStyle(.white)
                }
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = true }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            Theme.headerGreen
                .clipShape(RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight]))
        )
    }

    private var topCards: some View {
        HStack(alignment: .top, spacing: 14) {
            Button { showMineralsDetail = true } label: { MineralsCard() }
                .buttonStyle(CardButtonStyle())

            VStack(spacing: 14) {
                Button { showDrinkDetail = true } label: {
                    InfoCard(
                        icon: "waterbottle.fill",
                        iconColor: .red,
                        background: Theme.drinkPink,
                        title: "Restant à boire",
                        value: "389ml",
                        progress: 0.45,
                        progressColor: .red
                    )
                }.buttonStyle(CardButtonStyle())

                Button { showHeatingDetail = true } label: {
                    InfoCard(
                        icon: "thermometer.medium",
                        iconColor: Theme.darkGreen,
                        background: Theme.heatPurple,
                        title: "Mode Chauffage",
                        value: "21°C",
                        progress: nil,
                        progressColor: .clear
                    )
                }.buttonStyle(CardButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }

    private var centerMessage: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 70, height: 1)
                ZStack {
                    Circle().fill(Theme.headerGreen.opacity(0.6)).frame(width: 78, height: 78)
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Theme.darkGreen)
                }
                Rectangle().fill(Color.gray.opacity(0.4)).frame(width: 70, height: 1)
            }
            Text("Prenez soin de vous")
                .font(.title3.bold())
                .foregroundStyle(Theme.darkGreen)
            Text("Votre santé est notre priorité")
                .font(.subheadline)
                .foregroundStyle(Theme.darkGreen.opacity(0.8))
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button {} label: {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                    Text("Accueil").font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }

            Rectangle().fill(Color.white.opacity(0.4)).frame(width: 1, height: 28)

            Button { showLocationAlert = true } label: {
                VStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Localisation").font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 14)
        .background(Theme.darkGreen, in: RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }
}

// MARK: - Cards

struct MineralsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(.blue)
                Text("Minéraux").font(.headline).foregroundStyle(.blue)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.gray)
            }
            HStack(spacing: 18) {
                MineralBar(label: "Fer", value: 0.35, color: .pink)
                MineralBar(label: "Zinc", value: 0.6, color: .green)
                MineralBar(label: "Calcium", value: 0.55, color: .yellow)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.mineralsBlue, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct MineralBar: View {
    let label: String
    let value: CGFloat
    let color: Color
    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 6).fill(Color.white)
                    RoundedRectangle(cornerRadius: 6).fill(color)
                        .frame(height: geo.size.height * value)
                }
            }
            .frame(width: 18, height: 70)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let background: Color
    let title: String
    let value: String
    let progress: CGFloat?
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundStyle(iconColor)
                Text(title).font(.caption.weight(.medium)).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.gray)
            }
            Text(value).font(.title3.bold())
            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.7))
                        Capsule().fill(progressColor).frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 20))
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
    @Binding var showPanel: Bool
    @Binding var showSettingsPanel: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Menu").font(.title2.bold())
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
                } label: {
                    Image(systemName: "xmark").foregroundStyle(.secondary)
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            Divider()

            panelRow(icon: "gearshape.fill", title: "Paramètres") {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
                showSettingsPanel = true
            }
            panelRow(icon: "person.crop.circle", title: "Mon profil") {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
            }
            panelRow(icon: "bell.fill", title: "Notifications") {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
            }
            panelRow(icon: "questionmark.circle.fill", title: "Aide") {
                withAnimation(.easeInOut(duration: 0.25)) { showPanel = false }
            }

            Spacer()
        }
        .frame(width: 260)
        .frame(maxHeight: .infinity)
        .background(.white)
        .ignoresSafeArea()
    }

    private func panelRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).foregroundStyle(Theme.darkGreen).frame(width: 24)
                Text(title).foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
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
                Image(systemName: "hourglass").font(.system(size: 44)).foregroundStyle(Theme.darkGreen)
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
