import Foundation

enum WorkPhase: String, Codable {
    case sitting = "sitting"
    case standing = "standing"

    var displayName: String {
        switch self {
        case .sitting: return "坐姿"
        case .standing: return "站立"
        }
    }

    var next: WorkPhase {
        switch self {
        case .sitting: return .standing
        case .standing: return .sitting
        }
    }
}
