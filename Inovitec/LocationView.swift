import SwiftUI
import MapKit
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        status = manager.authorizationStatus
    }

    func start() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
    }

    func stop() { manager.stopUpdatingLocation() }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

struct LocationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var lm = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.6116, longitude: 6.1319),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var tracking: MapUserTrackingMode = .follow
    @State private var showSOS = false

    private var denied: Bool { lm.status == .denied || lm.status == .restricted }

    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $tracking)
                .ignoresSafeArea()

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Theme.headerGradient, in: Circle())
                }
                Spacer()
                Text("Localisation")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Theme.headerGradient, in: Capsule())
                Spacer()
                Button { tracking = .follow } label: {
                    Image(systemName: "location.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Theme.headerGradient, in: Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Spacer()
                    Button { showSOS = true } label: {
                        Label("Appeler les secours", systemImage: "phone.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18).padding(.vertical, 14)
                            .background(Color(red: 0.85, green: 0.10, blue: 0.15), in: Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                    }
                }
                infoCard
            }
            .padding(16)
        }
        .fullScreenCover(isPresented: $showSOS) { EmergencyCallView() }
        .onAppear { lm.start() }
        .onDisappear { lm.stop() }
    }

    @ViewBuilder
    private var infoCard: some View {
        VStack(spacing: 6) {
            if denied {
                Label("Accès à la position refusé", systemImage: "location.slash.fill")
                    .font(.headline)
                Button("Ouvrir les réglages") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            } else if let loc = lm.location {
                Label("Position en temps réel", systemImage: "location.circle.fill")
                    .font(.headline).foregroundStyle(Theme.accent)
                Text(String(format: "%.5f, %.5f", loc.coordinate.latitude, loc.coordinate.longitude))
                    .font(.subheadline.monospacedDigit())
                Text(String(format: "Précision : ±%.0f m", loc.horizontalAccuracy))
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Recherche de votre position…").font(.subheadline)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
