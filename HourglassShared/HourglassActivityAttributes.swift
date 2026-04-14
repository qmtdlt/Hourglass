import ActivityKit
import Foundation

struct HourglassActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var phase: Phase
        var mode: Mode
        var phaseEndDate: Date?
        var pausedRemainingTime: TimeInterval?
    }

    enum Phase: String, Codable, Hashable {
        case sitting
        case standing
    }

    enum Mode: String, Codable, Hashable {
        case running
        case paused
        case needsFlip
    }

    var sessionID: String
}
