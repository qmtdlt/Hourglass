import Foundation

struct AppSettings: Codable {
    var sittingDuration: TimeInterval = 30 * 60
    var standingDuration: TimeInterval = 30 * 60
    var flipSensitivity: Double = 2.0
    var soundEnabled: Bool = true
    var hapticEnabled: Bool = true

    static let `default` = AppSettings()
}
