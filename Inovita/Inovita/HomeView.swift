import SwiftUI

struct HomeView: View {
    @EnvironmentObject var ble: BluetoothManager
    @State private var selected: DeviceKind?
    private let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "link.circle.fill").font(.largeTitle).foregroundStyle(Theme.accent)
                        VStack(alignment: .leading) {
                            Text("\(ble.connected.count) of \(DeviceKind.allCases.count) connected").font(.headline)
                            Text("Tap a device to pair it with Inovita").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    Text("Your devices").font(.title3.bold())
                    LazyVGrid(columns: cols, spacing: 14) {
                        ForEach(DeviceKind.allCases) { kind in
                            DeviceCard(kind: kind, connected: ble.connected[kind])
                                .onTapGesture { selected = kind }
                        }
                    }
                }.padding()
            }
            .navigationTitle("Inovita")
            .sheet(item: $selected) { kind in
                DeviceScanView(kind: kind).environmentObject(ble)
            }
        }
    }
}

struct DeviceCard: View {
    let kind: DeviceKind
    let connected: FoundDevice?
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(kind.color.opacity(0.15)).frame(width: 48, height: 48)
                Image(systemName: kind.icon).font(.title2).foregroundStyle(kind.color)
            }
            Text(kind.title).font(.headline)
            Text(connected?.name ?? kind.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            HStack(spacing: 6) {
                Circle().fill(connected == nil ? Color.gray : Color.green).frame(width: 8, height: 8)
                Text(connected == nil ? "Not connected" : "Connected").font(.caption2.weight(.medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct DeviceScanView: View {
    let kind: DeviceKind
    @EnvironmentObject var ble: BluetoothManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let d = ble.connected[kind] {
                    Section("Connected") {
                        Label(d.name, systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Button("Disconnect", role: .destructive) { ble.disconnect(kind); ble.startScan(for: kind) }
                    }
                } else if !ble.isReady {
                    Section { Text(ble.stateMessage.isEmpty ? "Starting Bluetooth…" : ble.stateMessage).foregroundStyle(.secondary) }
                } else {
                    Section {
                        ForEach(ble.found) { dev in
                            Button {
                                ble.connect(dev, as: kind)
                            } label: {
                                HStack {
                                    Image(systemName: kind.icon).foregroundStyle(kind.color)
                                    VStack(alignment: .leading) {
                                        Text(dev.name).foregroundStyle(.primary)
                                        Text("Signal \(dev.rssi) dBm").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if ble.connectingID == dev.id { ProgressView() }
                                }
                            }
                        }
                    } header: {
                        HStack { Text("Nearby devices"); if ble.isScanning { ProgressView().scaleEffect(0.7) } }
                    } footer: {
                        if ble.found.isEmpty { Text("Make sure your \(kind.title.lowercased()) is on and in pairing mode.") }
                    }
                }
                if let e = ble.errorMessage { Section { Text(e).foregroundStyle(.red) } }
            }
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .topBarLeading) {
                    if ble.connected[kind] == nil {
                        Button { ble.startScan(for: kind) } label: { Image(systemName: "arrow.clockwise") }
                    }
                }
            }
            .onAppear { if ble.connected[kind] == nil { ble.startScan(for: kind) } }
            .onDisappear { ble.stopScan() }
        }
    }
}
