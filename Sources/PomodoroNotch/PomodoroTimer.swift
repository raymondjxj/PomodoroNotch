import SwiftUI
import Combine

// MARK: - Phase

indirect enum TimerPhase: Equatable, Codable {
    case idle
    case focus
    case shortBreak
    case longBreak
    case paused(underlying: TimerPhase)

    var isWorking: Bool {
        switch self {
        case .focus, .paused(.focus): return true
        default: return false
        }
    }

    var isBreak: Bool {
        switch self {
        case .shortBreak, .longBreak, .paused(.shortBreak), .paused(.longBreak): return true
        default: return false
        }
    }

    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    var label: String {
        switch self {
        case .idle: return "idle"
        case .focus: return "focus"
        case .shortBreak: return "short_break"
        case .longBreak: return "long_break"
        case .paused(let u): return "paused_\(u.label)"
        }
    }

    var color: Color {
        switch self {
        case .focus: return Color(red: 1.0, green: 0.42, blue: 0.23)
        case .shortBreak, .longBreak: return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .paused: return Color(red: 0.56, green: 0.56, blue: 0.58)
        case .idle: return .secondary
        }
    }

    var icon: String {
        switch self {
        case .focus: return "🍅"
        case .shortBreak, .longBreak: return "☕"
        case .paused(let u): return u.icon
        case .idle: return ""
        }
    }
}

// MARK: - Timer Engine

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var remainingSeconds: Int = 0
    @Published var currentRound: Int = 0

    private var timer: Timer?
    private var phaseStartedAt: Date?
    let preferences: PreferencesStore

    // MARK: - Init

    init(preferences: PreferencesStore) {
        self.preferences = preferences
        restoreState()
    }

    // MARK: - Computed

    var totalSeconds: Int {
        switch phase {
        case .idle: return 0
        case .focus, .paused(.focus): return preferences.focusDuration * 60
        case .shortBreak, .paused(.shortBreak): return preferences.shortBreakDuration * 60
        case .longBreak, .paused(.longBreak): return preferences.longBreakDuration * 60
        case .paused: return 0
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var displayString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Actions

    func startOrPause() {
        switch phase {
        case .idle:
            startFocus()
        case .focus, .shortBreak, .longBreak:
            pause()
        case .paused(let underlying):
            resume(underlying)
        }
    }

    func startFocus() {
        currentRound += 1
        phase = .focus
        remainingSeconds = preferences.focusDuration * 60
        startTick()
        saveState()
    }

    func skip() {
        stopTick()
        switch phase {
        case .focus, .paused(.focus):
            startBreak()
        case .shortBreak, .longBreak, .paused(.shortBreak), .paused(.longBreak):
            startFocus()
        case .idle:
            startFocus()
        case .paused(.idle), .paused(.paused):
            startFocus() // unreachable but required for exhaustiveness
        }
    }

    func reset() {
        stopTick()
        phase = .idle
        remainingSeconds = 0
        currentRound = 0
        clearState()
    }

    // MARK: - Private

    private func pause() {
        let underlying: TimerPhase
        switch phase {
        case .focus: underlying = .focus
        case .shortBreak: underlying = .shortBreak
        case .longBreak: underlying = .longBreak
        default: return
        }
        stopTick()
        phase = .paused(underlying: underlying)
        saveState()
    }

    private func resume(_ underlying: TimerPhase) {
        phase = underlying
        startTick()
        saveState()
    }

    private func startBreak() {
        let isLong = currentRound % preferences.longBreakInterval == 0
        phase = isLong ? .longBreak : .shortBreak
        remainingSeconds = isLong
            ? preferences.longBreakDuration * 60
            : preferences.shortBreakDuration * 60
        startTick()
        saveState()
    }

    private func startTick() {
        timer?.invalidate()
        phaseStartedAt = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    private func stopTick() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            onComplete()
            return
        }
        remainingSeconds -= 1

        if preferences.tickEnabled && phase == .focus && remainingSeconds <= 60 && remainingSeconds > 0 {
            NotificationCenter.default.post(name: .pomodoroTick, object: self)
        }

        if remainingSeconds == 0 {
            onComplete()
        }
    }

    private func onComplete() {
        stopTick()

        // Notify listeners with the COMPLETED phase (before it changes)
        NotificationCenter.default.post(
            name: .pomodoroPhaseCompleted,
            object: self,
            userInfo: ["phase": phase]
        )

        if preferences.autoStartNext {
            switch phase {
            case .focus:
                startBreak()
            case .shortBreak, .longBreak:
                startFocus()
            default:
                phase = .idle
                saveState()
            }
        } else {
            // Stay on the completed phase with 0 remaining
            saveState()
        }
    }

    // MARK: - Persistence

    private let defaults = UserDefaults.standard
    private let phaseKey = "pomodoro.phase"
    private let remainingKey = "pomodoro.remaining"
    private let roundKey = "pomodoro.round"
    private let startedAtKey = "pomodoro.startedAt"

    private func saveState() {
        let data: [String: Any] = [
            phaseKey: phase.label,
            remainingKey: remainingSeconds,
            roundKey: currentRound,
            startedAtKey: phaseStartedAt?.timeIntervalSince1970 ?? 0
        ]
        defaults.set(data, forKey: "pomodoro.state")
    }

    private func restoreState() {
        guard let data = defaults.dictionary(forKey: "pomodoro.state"),
              let phaseLabel = data[phaseKey] as? String,
              let remaining = data[remainingKey] as? Int,
              let round = data[roundKey] as? Int,
              let startedAt = data[startedAtKey] as? TimeInterval
        else { return }

        self.phase = Self.parsePhase(phaseLabel)
        self.currentRound = round

        if startedAt > 0, !self.phase.isPaused, self.phase != .idle {
            // Recalculate elapsed time
            let elapsed = Int(Date().timeIntervalSince1970 - startedAt)
            let total = self.totalSeconds
            self.remainingSeconds = max(0, total - elapsed)
            if self.remainingSeconds > 0 {
                startTick()
            } else {
                onComplete()
            }
        } else {
            self.remainingSeconds = remaining
        }
    }

    private static func parsePhase(_ label: String) -> TimerPhase {
        switch label {
        case "idle": return .idle
        case "focus": return .focus
        case "short_break": return .shortBreak
        case "long_break": return .longBreak
        case "paused_focus": return .paused(underlying: .focus)
        case "paused_short_break": return .paused(underlying: .shortBreak)
        case "paused_long_break": return .paused(underlying: .longBreak)
        default: return .idle
        }
    }

    private func clearState() {
        defaults.removeObject(forKey: "pomodoro.state")
        phaseStartedAt = nil
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let pomodoroPhaseCompleted = Notification.Name("pomodoroPhaseCompleted")
    static let pomodoroTick = Notification.Name("pomodoroTick")
}
