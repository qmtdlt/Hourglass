import ActivityKit
import Foundation

final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    func start(sessionID: UUID, phase: WorkPhase, endDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = HourglassActivityAttributes(sessionID: sessionID.uuidString)
        let state = HourglassActivityAttributes.ContentState(
            phase: phase.liveActivityPhase,
            mode: .running,
            phaseEndDate: endDate,
            pausedRemainingTime: nil
        )

        Task {
            await endAll(dismissalPolicy: .immediate)

            do {
                _ = try Activity<HourglassActivityAttributes>.request(
                    attributes: attributes,
                    content: .init(state: state, staleDate: endDate),
                    pushType: nil
                )
            } catch {
                #if DEBUG
                print("Failed to start Live Activity: \(error)")
                #endif
            }
        }
    }

    func updateRunning(phase: WorkPhase, endDate: Date) {
        let state = HourglassActivityAttributes.ContentState(
            phase: phase.liveActivityPhase,
            mode: .running,
            phaseEndDate: endDate,
            pausedRemainingTime: nil
        )

        Task {
            await updateAll(with: state, staleDate: endDate)
        }
    }

    func updatePaused(phase: WorkPhase, remainingTime: TimeInterval) {
        let state = HourglassActivityAttributes.ContentState(
            phase: phase.liveActivityPhase,
            mode: .paused,
            phaseEndDate: nil,
            pausedRemainingTime: remainingTime
        )

        Task {
            await updateAll(with: state, staleDate: nil)
        }
    }

    func updateNeedsFlip(phase: WorkPhase) {
        let state = HourglassActivityAttributes.ContentState(
            phase: phase.liveActivityPhase,
            mode: .needsFlip,
            phaseEndDate: nil,
            pausedRemainingTime: nil
        )

        Task {
            await updateAll(with: state, staleDate: nil)
        }
    }

    func end() {
        Task {
            await endAll(dismissalPolicy: .immediate)
        }
    }

    private func updateAll(with state: HourglassActivityAttributes.ContentState, staleDate: Date?) async {
        let content = ActivityContent(state: state, staleDate: staleDate)

        for activity in Activity<HourglassActivityAttributes>.activities {
            await activity.update(content)
        }
    }

    private func endAll(dismissalPolicy: ActivityUIDismissalPolicy) async {
        for activity in Activity<HourglassActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: dismissalPolicy)
        }
    }
}

private extension WorkPhase {
    var liveActivityPhase: HourglassActivityAttributes.Phase {
        switch self {
        case .sitting:
            return .sitting
        case .standing:
            return .standing
        }
    }
}
