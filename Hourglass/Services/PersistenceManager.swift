import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let settingsKey = "app_settings"
    private let sessionsKey = "cycle_sessions"

    private init() {}

    // MARK: - Settings

    func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings.default
        }
        return settings
    }

    func saveSettings(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    // MARK: - Sessions

    func loadSessions() -> [CycleSession] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([CycleSession].self, from: data) else {
            return []
        }
        return sessions
    }

    func saveSession(_ session: CycleSession) {
        var sessions = loadSessions()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }

    func sessionsForDate(_ date: Date) -> [CycleSession] {
        let calendar = Calendar.current
        return loadSessions().filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
    }
}
