import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var sessions: [CycleSession] = []

    func load() {
        sessions = PersistenceManager.shared.loadSessions()
            .sorted { $0.startedAt > $1.startedAt }
    }

    func sessionsForDate(_ date: Date) -> [CycleSession] {
        PersistenceManager.shared.sessionsForDate(date)
    }

    func totalSittingTime(for date: Date) -> TimeInterval {
        sessionsForDate(date).map(\.totalSittingTime).reduce(0, +)
    }

    func totalStandingTime(for date: Date) -> TimeInterval {
        sessionsForDate(date).map(\.totalStandingTime).reduce(0, +)
    }

    func completedCycles(for date: Date) -> Int {
        sessionsForDate(date).map(\.completedCycles).reduce(0, +)
    }
}
