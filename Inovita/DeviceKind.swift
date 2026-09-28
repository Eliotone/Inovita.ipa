import SwiftUI

enum DeviceKind: String, CaseIterable, Identifiable {
    case chip, bottle, fork, clothes, watch, shoes
    var id: String { rawValue }

    var title: String {
        switch self {
        case .chip: return "Medical Chip"
        case .bottle: return "Smart Bottle"
        case .fork: return "Smart Fork"
        case .clothes: return "Smart Clothes"
        case .watch: return "Smart Watch"
        case .shoes: return "Smart Shoes"
        }
    }
    var subtitle: String {
        switch self {
        case .chip: return "Vitals & health data"
        case .bottle: return "Hydration tracking"
        case .fork: return "Eating habits"
        case .clothes: return "Body temperature & posture"
        case .watch: return "Activity & heart rate"
        case .shoes: return "Steps & gait analysis"
        }
    }
    var icon: String {
        switch self {
        case .chip: return "cpu"
        case .bottle: return "waterbottle.fill"
        case .fork: return "fork.knife"
        case .clothes: return "tshirt.fill"
        case .watch: return "applewatch"
        case .shoes: return "shoeprints.fill"
        }
    }
    var color: Color {
        switch self {
        case .chip: return .red
        case .bottle: return .blue
        case .fork: return .orange
        case .clothes: return .purple
        case .watch: return .pink
        case .shoes: return .green
        }
    }
}
