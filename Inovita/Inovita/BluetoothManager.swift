import CoreBluetooth
import Foundation

struct FoundDevice: Identifiable {
    let id: UUID
    let name: String
    var rssi: Int
}

final class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var state: CBManagerState = .unknown
    @Published var found: [FoundDevice] = []
    @Published var isScanning = false
    @Published var connectingID: UUID?
    @Published var errorMessage: String?
    /// Connected device per category (name + id)
    @Published var connected: [DeviceKind: FoundDevice] = [:]

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var kindForPeripheral: [UUID: DeviceKind] = [:]
    private var pendingKind: DeviceKind?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    var isReady: Bool { state == .poweredOn }

    var stateMessage: String {
        switch state {
        case .poweredOff: return "Bluetooth is turned off. Turn it on in Settings."
        case .unauthorized: return "Bluetooth permission denied. Enable it in Settings > Inovita."
        case .unsupported: return "Bluetooth is not supported on this device."
        default: return ""
        }
    }

    func startScan(for kind: DeviceKind) {
        pendingKind = kind
        found.removeAll()
        errorMessage = nil
        guard isReady else { return }
        isScanning = true
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScan() {
        central.stopScan()
        isScanning = false
    }

    func connect(_ device: FoundDevice, as kind: DeviceKind) {
        guard let p = peripherals[device.id] else { return }
        pendingKind = kind
        connectingID = device.id
        kindForPeripheral[device.id] = kind
        central.connect(p, options: nil)
        // timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            guard let self, self.connectingID == device.id else { return }
            self.central.cancelPeripheralConnection(p)
            self.connectingID = nil
            self.errorMessage = "Connection timed out."
        }
    }

    func disconnect(_ kind: DeviceKind) {
        guard let d = connected[kind], let p = peripherals[d.id] else { return }
        central.cancelPeripheralConnection(p)
        connected[kind] = nil
    }

    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        state = central.state
        if central.state != .poweredOn { isScanning = false }
        else if let k = pendingKind, isScanning == false, found.isEmpty, k == pendingKind, scanWanted {
            startScan(for: k)
        }
    }
    private var scanWanted: Bool { pendingKind != nil && connected[pendingKind!] == nil }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
        guard let name, !name.isEmpty else { return }
        peripherals[peripheral.identifier] = peripheral
        let dev = FoundDevice(id: peripheral.identifier, name: name, rssi: RSSI.intValue)
        if let i = found.firstIndex(where: { $0.id == dev.id }) { found[i] = dev }
        else { found.append(dev); found.sort { $0.rssi > $1.rssi } }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let id = peripheral.identifier
        connectingID = nil
        guard let kind = kindForPeripheral[id] else { return }
        connected[kind] = FoundDevice(id: id, name: peripheral.name ?? "Device", rssi: found.first { $0.id == id }?.rssi ?? 0)
        stopScan()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectingID = nil
        errorMessage = error?.localizedDescription ?? "Could not connect."
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let kind = kindForPeripheral[peripheral.identifier], connected[kind]?.id == peripheral.identifier {
            connected[kind] = nil
        }
    }
}
