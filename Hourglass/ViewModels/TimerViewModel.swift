import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var state: SessionState = .idle
    @Published var currentPhase: WorkPhase = .sitting
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var rotationDegrees: Double = 0   // 累计旋转角度，控制 UI 旋转方向

    @Published var settings: AppSettings {
        didSet { PersistenceManager.shared.saveSettings(settings) }
    }

    var isFlipped: Bool { Int(rotationDegrees / 180) % 2 != 0 }

    private var timer: AnyCancellable?
    private var currentSession: CycleSession?
    private var currentPhaseStart: Date?
    private var currentPhaseEnd: Date?
    private var currentPhasePlannedDuration: TimeInterval = 0
    private var motionManager = MotionManager()

    init() {
        self.settings = PersistenceManager.shared.loadSettings()
        setupMotion()
    }

    // MARK: - Controls

    func start() {
        let phaseDuration = settings.sittingDuration
        currentPhase = .sitting
        rotationDegrees = 0
        currentPhasePlannedDuration = phaseDuration
        remainingTime = phaseDuration
        progress = 0
        currentSession = CycleSession(id: UUID(), startedAt: Date(), phases: [])
        currentPhaseStart = Date()
        currentPhaseEnd = Date().addingTimeInterval(phaseDuration)
        state = .running
        if let sessionID = currentSession?.id, let endDate = currentPhaseEnd {
            LiveActivityManager.shared.start(sessionID: sessionID, phase: currentPhase, endDate: endDate)
        }
        AudioManager.shared.playStart()
        motionManager.startMonitoring()
        startTick()
    }

    func pause() {
        guard state == .running else { return }
        syncRemainingTime()
        state = .paused
        currentPhaseEnd = nil
        LiveActivityManager.shared.updatePaused(phase: currentPhase, remainingTime: remainingTime)
        timer?.cancel()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        currentPhaseEnd = Date().addingTimeInterval(remainingTime)
        if let endDate = currentPhaseEnd {
            LiveActivityManager.shared.updateRunning(phase: currentPhase, endDate: endDate)
        }
        startTick()
    }

    func reset() {
        timer?.cancel()
        motionManager.stopMonitoring()
        syncRemainingTime()
        recordCurrentPhase(completed: false)
        if var session = currentSession {
            session.endedAt = Date()
            PersistenceManager.shared.saveSession(session)
        }
        currentSession = nil
        currentPhaseStart = nil
        currentPhaseEnd = nil
        currentPhasePlannedDuration = 0
        state = .idle
        remainingTime = 0
        progress = 0
        rotationDegrees = 0
        LiveActivityManager.shared.end()
    }

    func skipPhase() {
        switch state {
        case .finished:
            advanceToNextPhase(recordCurrentPhaseBeforeAdvance: false, completed: true, flipDirection: 1)
        case .running, .paused:
            advanceToNextPhase(recordCurrentPhaseBeforeAdvance: true, completed: false, flipDirection: 1)
        case .idle:
            break
        }
    }

    // MARK: - Private

    private func startTick() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        guard state == .running else { return }
        syncRemainingTime()
        if remainingTime <= 0 { phaseCompleted() }
    }

    private func phaseCompleted() {
        timer?.cancel()
        currentPhaseEnd = nil
        remainingTime = 0
        progress = 1
        state = .finished
        recordCurrentPhase(completed: true)
        LiveActivityManager.shared.updateNeedsFlip(phase: currentPhase)
        AudioManager.shared.playPhaseComplete()
        if settings.hapticEnabled { AudioManager.shared.vibrate() }
    }

    private func advanceToNextPhase(recordCurrentPhaseBeforeAdvance: Bool, completed: Bool, flipDirection: Int) {
        timer?.cancel()
        syncRemainingTime()
        if recordCurrentPhaseBeforeAdvance {
            recordCurrentPhase(completed: completed)
        }
        currentPhase = currentPhase.next
        let nextDuration = duration(for: currentPhase)
        rotationDegrees += Double(flipDirection) * 180
        currentPhasePlannedDuration = nextDuration
        remainingTime = nextDuration
        progress = 0
        currentPhaseStart = Date()
        currentPhaseEnd = Date().addingTimeInterval(nextDuration)
        state = .running
        if let endDate = currentPhaseEnd {
            LiveActivityManager.shared.updateRunning(phase: currentPhase, endDate: endDate)
        }
        startTick()
    }

    private func recordCurrentPhase(completed: Bool) {
        guard var session = currentSession, let start = currentPhaseStart else { return }
        let total = currentPhasePlannedDuration
        let actual = max(0, total - remainingTime)
        let record = PhaseRecord(
            id: UUID(),
            phase: currentPhase,
            plannedDuration: total,
            actualDuration: actual,
            completed: completed,
            startedAt: start
        )
        session.phases.append(record)
        currentSession = session
        PersistenceManager.shared.saveSession(session)
    }

    private func setupMotion() {
        motionManager.onFlipDetected = { [weak self] direction in
            guard let self, self.state == .finished else { return }
            AudioManager.shared.playFlipConfirm()
            self.advanceToNextPhase(recordCurrentPhaseBeforeAdvance: false, completed: true, flipDirection: direction)
        }
    }

    private func duration(for phase: WorkPhase) -> TimeInterval {
        switch phase {
        case .sitting:
            return settings.sittingDuration
        case .standing:
            return settings.standingDuration
        }
    }

    private func syncRemainingTime(now: Date = Date()) {
        guard currentPhasePlannedDuration > 0 else {
            remainingTime = 0
            progress = 0
            return
        }

        if state == .running, let end = currentPhaseEnd {
            remainingTime = max(0, end.timeIntervalSince(now))
        }

        progress = min(max(1.0 - (remainingTime / currentPhasePlannedDuration), 0), 1)
    }
}
