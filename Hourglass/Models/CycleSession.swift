import Foundation

enum SessionState {
    case idle
    case running
    case paused
    case finished
}

struct PhaseRecord: Codable, Identifiable {
    let id: UUID
    let phase: WorkPhase
    let plannedDuration: TimeInterval
    let actualDuration: TimeInterval
    let completed: Bool
    let startedAt: Date
}

struct CycleSession: Codable, Identifiable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    var phases: [PhaseRecord]

    var totalSittingTime: TimeInterval {
        phases.filter { $0.phase == .sitting }.map(\.actualDuration).reduce(0, +)
    }

    var totalStandingTime: TimeInterval {
        phases.filter { $0.phase == .standing }.map(\.actualDuration).reduce(0, +)
    }

    var completedCycles: Int {
        var count = 0
        var i = 0
        while i + 1 < phases.count {
            if phases[i].completed && phases[i + 1].completed {
                count += 1
                i += 2
            } else {
                i += 1
            }
        }
        return count
    }
}
