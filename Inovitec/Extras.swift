import SwiftUI
import Combine

// MARK: - Emergency call screen (graphic only)

struct EmergencyCallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pulse = false
    @State private var seconds = 0
    @State private var dragX: CGFloat = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let red = Color(red: 0.85, green: 0.10, blue: 0.15)

    private var timeString: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [red, Color(red: 0.50, green: 0.03, blue: 0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                ZStack {
                    Circle().stroke(Color.white.opacity(0.35), lineWidth: 3)
                        .frame(width: 230, height: 230)
                        .scaleEffect(pulse ? 1.35 : 0.8)
                        .opacity(pulse ? 0 : 1)
                    Circle().stroke(Color.white.opacity(0.35), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulse ? 1.3 : 0.8)
                        .opacity(pulse ? 0 : 1)
                    Circle().fill(Color.white).frame(width: 130, height: 130)
                    Image(systemName: "phone.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(red)
                }
                Text("Appel des secours")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("Connexion au 112…")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                Text(timeString)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white)
                Label("Votre position est partagée", systemImage: "location.fill")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                cancelSlider
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) { pulse = true }
        }
        .onReceive(timer) { _ in seconds += 1 }
    }

    private var cancelSlider: some View {
        GeometryReader { geo in
            let knob: CGFloat = 56
            let maxX = geo.size.width - knob - 8
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.22))
                Text("Glisser pour annuler")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .opacity(1 - Double(dragX / max(maxX, 1)))
                Circle().fill(Color.white)
                    .frame(width: knob, height: knob)
                    .overlay(Image(systemName: "xmark").font(.headline).foregroundStyle(red))
                    .offset(x: 4 + dragX)
                    .gesture(
                        DragGesture()
                            .onChanged { v in dragX = min(max(0, v.translation.width), maxX) }
                            .onEnded { _ in
                                if dragX > maxX * 0.85 { dismiss() }
                                else { withAnimation(.spring()) { dragX = 0 } }
                            }
                    )
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 28)
        .padding(.bottom, 34)
    }
}

// MARK: - Shortcut card

struct ShortcutCard: View {
    let icon: String
    let iconColor: Color
    let gradient: LinearGradient
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).font(.title2).foregroundStyle(iconColor)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            Text(title).font(.subheadline.weight(.bold)).foregroundStyle(.primary)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(gradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

// MARK: - Injury duration page (fake data)

struct InjuryDurationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ZStack {
                        Circle().stroke(Theme.roseBar.opacity(0.25), lineWidth: 18)
                        Circle().trim(from: 0, to: 0.4)
                            .stroke(Theme.roseBar, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 2) {
                            Text("12").font(.system(size: 54, weight: .bold))
                            Text("jours restants").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding(.top, 20)

                    VStack(spacing: 0) {
                        infoRow("Type de blessure", "Entorse de la cheville")
                        Divider()
                        infoRow("Gravité", "Modérée")
                        Divider()
                        infoRow("Durée totale estimée", "20 jours")
                        Divider()
                        infoRow("Reprise du sport", "Dans 3 semaines")
                    }
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 14) {
                        step("Jour 1 – 3", "Repos et glace", done: true)
                        step("Jour 4 – 10", "Mobilité douce", done: true)
                        step("Jour 11 – 20", "Renforcement", done: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
            }
            .navigationTitle("Durée de blessure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } }
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .padding(.vertical, 14)
    }

    private func step(_ range: String, _ text: String, done: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? Theme.accent : Color.gray)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(range).font(.caption).foregroundStyle(.secondary)
                Text(text).font(.subheadline.weight(.semibold))
            }
        }
    }
}

// MARK: - Fake book page

struct BookView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var opened = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                if opened { openBook.transition(.scale.combined(with: .opacity)) }
                else { closedBook.transition(.scale.combined(with: .opacity)) }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { opened.toggle() }
                } label: {
                    Text("Afficher")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.barGradient, in: Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity)
            .background(Theme.background)
            .navigationTitle("Bibliothèque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Fermer") { dismiss() } }
            }
        }
    }

    private var closedBook: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [Theme.forest, Theme.forestDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 210, height: 290)
                .shadow(color: .black.opacity(0.3), radius: 12, x: 6, y: 8)
            Rectangle().fill(Color.black.opacity(0.25)).frame(width: 18, height: 290)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(spacing: 14) {
                Image(systemName: "leaf.fill").font(.system(size: 40)).foregroundStyle(Theme.sun)
                Text("Guide de santé").font(.title3.bold()).foregroundStyle(.white)
                Rectangle().fill(Theme.sun).frame(width: 60, height: 2)
                Text("Inovitec").font(.subheadline).foregroundStyle(.white.opacity(0.85))
            }
            .frame(width: 210)
            .padding(.leading, 10)
        }
        .frame(width: 210, height: 290)
    }

    private var openBook: some View {
        HStack(spacing: 2) {
            page
            page
        }
        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
    }

    private var page: some View {
        VStack(alignment: .leading, spacing: 10) {
            Capsule().fill(Color.gray.opacity(0.5)).frame(width: 90, height: 10)
            ForEach(0..<12, id: \.self) { i in
                Capsule().fill(Color.gray.opacity(0.25))
                    .frame(width: i % 4 == 3 ? 80 : 140, height: 6)
            }
        }
        .padding(18)
        .frame(width: 168, height: 290, alignment: .topLeading)
        .background(Color(light: .white, dark: Color(hex: 0x2a2f33)), in: RoundedRectangle(cornerRadius: 6))
    }
}
