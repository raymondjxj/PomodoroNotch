import SwiftUI
import Combine
import AppKit
import ServiceManagement

// MARK: - Notifications

extension Notification.Name {
    static let shortcutToggle  = Notification.Name("pomodoro.shortcut.toggle")
    static let shortcutSkip    = Notification.Name("pomodoro.shortcut.skip")
    static let shortcutReset   = Notification.Name("pomodoro.shortcut.reset")
    static let openPreferences = Notification.Name("pomodoro.openPreferences")
}

// MARK: - Menu Bar Label

struct TimerLabel: View {
    @ObservedObject var timer: PomodoroTimer
    @AppStorage("prefs.displayMode") var displayMode: String = "timeOnly"
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 2) {
            if timer.phase == .idle {
                Text("·")
            } else if displayMode == "timeWithIcon" {
                Text("\(timer.phase.icon)\(timer.remainingSeconds / 60)m")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            } else {
                Text(timer.displayString)
                    .font(.system(size: 12, weight: lastMinute ? .bold : .medium, design: .monospaced))
            }
        }
        .foregroundColor(timer.phase.color)
        .opacity(isPulsing ? 0.4 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: timer.phase)
        .animation(isPulsing ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isPulsing)
        .onChange(of: timer.phase) { _, newPhase in isPulsing = newPhase.isPaused }
    }

    private var lastMinute: Bool {
        timer.phase.isWorking && !timer.phase.isPaused && timer.remainingSeconds <= 60 && timer.remainingSeconds > 0
    }
}

// MARK: - Dropdown Panel (§3.2)

struct DropdownPanel: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var stats: StatisticsStore
    @AppStorage("prefs.language") private var language: String = "auto"

    var body: some View {
        VStack(spacing: 0) {
            statusHeader.padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 6)
            largeTimer.padding(.bottom, 12)
            controlRow.padding(.horizontal, 16).padding(.bottom, 12)
            Divider().padding(.horizontal, 12)
            statsSection.padding(.horizontal, 16).padding(.vertical, 10)
            Divider().padding(.horizontal, 12)
            footerSection.padding(.vertical, 4)
        }
        .frame(width: 240)
    }

    // MARK: Header

    private var statusHeader: some View {
        HStack(spacing: 6) {
            Text(timer.phase.icon.isEmpty ? "🍅" : timer.phase.icon).font(.system(size: 12))
            Text(statusTitle).font(.system(size: 13, weight: .medium))
            Spacer()
        }
    }

    private var statusTitle: String {
        switch timer.phase {
        case .idle:                         return L10n.tr("ready")
        case .focus:                        return String(format: L10n.tr("focus_round"), timer.currentRound)
        case .shortBreak:                   return L10n.tr("short_break")
        case .longBreak:                    return L10n.tr("long_break")
        case .paused(.focus):               return L10n.tr("focus_paused")
        case .paused:                       return L10n.tr("break_paused")
        }
    }

    // MARK: Timer

    private var largeTimer: some View {
        Text(timer.phase == .idle ? formatMinSec(timer.preferences.focusDuration) : timer.displayString)
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .foregroundColor(timer.phase.isIdle ? .secondary : timer.phase.color)
            .contentTransition(.numericText())
    }

    private func formatMinSec(_ minutes: Int) -> String {
        String(format: "%d:00", minutes)
    }

    // MARK: Controls

    private var controlRow: some View {
        HStack(spacing: 16) {
            controlButton(icon: primaryIcon, label: primaryLabel, shortcut: "⌃⌥⌘P", action: timer.startOrPause)
            if timer.phase != .idle {
                controlButton(icon: "forward.fill", label: L10n.tr("skip"), shortcut: "⌃⌥⌘S", action: timer.skip)
            }
        }
    }

    private var primaryIcon: String {
        (timer.phase == .idle || timer.phase.isPaused) ? "play.fill" : "pause.fill"
    }
    private var primaryLabel: String {
        timer.phase == .idle ? L10n.tr("start") : timer.phase.isPaused ? L10n.tr("continue") : L10n.tr("pause")
    }

    private func controlButton(icon: String, label: String, shortcut: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(systemName: icon).font(.system(size: 16)).frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .background(Circle().fill(.quaternary))
            Text(label).font(.system(size: 11))
            Text(shortcut).font(.system(size: 9)).foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Stats

    private var statsSection: some View {
        VStack(spacing: 4) {
            statRow("🍅 \(L10n.tr("today"))", String(format: L10n.tr("pomodoros_count"), stats.todayStats.completedPomodoros))
            statRow("⏱ \(L10n.tr("total_focus"))", formatSeconds(stats.todayStats.totalFocusSeconds))
            weeklyChart.padding(.top, 6)
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 12, weight: .medium))
        }
    }

    private var weeklyChart: some View {
        let items = stats.weekStats
        let maxVal = max(1, items.map(\.completedPomodoros).max() ?? 1)
        let labels = [L10n.tr("mon"), L10n.tr("tue"), L10n.tr("wed"), L10n.tr("thu"), L10n.tr("fri"), L10n.tr("sat"), L10n.tr("sun")]
        return HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, d in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(d.completedPomodoros > 0 ? Color.orange : Color.secondary.opacity(0.15))
                        .frame(width: 14, height: max(4, CGFloat(d.completedPomodoros) / CGFloat(maxVal) * 36))
                    Text(labels[i]).font(.system(size: 9)).foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 52)
    }

    // MARK: Footer

    private var footerSection: some View {
        VStack(spacing: 2) {
            Button(action: {
                NotificationCenter.default.post(name: .openPreferences, object: nil)
            }) {
                HStack {
                    Image(systemName: "gearshape").frame(width: 16)
                    Text("\(L10n.tr("preferences"))...")
                    Spacer()
                }
                .font(.system(size: 13))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16).padding(.vertical, 5)

            Button(action: { NSApp.terminate(nil) }) {
                HStack {
                    Image(systemName: "power").frame(width: 16)
                    Text(L10n.tr("quit"))
                    Spacer()
                }
                .font(.system(size: 13))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16).padding(.vertical, 5)
        }
    }

    private func formatSeconds(_ s: Int) -> String {
        if s < 60 { return "\(s)\(L10n.tr("seconds_unit"))" }
        let h = s / 3600, m = (s % 3600) / 60
        return h > 0 ? "\(h)h \(m)\(L10n.tr("minutes_unit"))" : "\(m) \(L10n.tr("minutes_unit"))"
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    let preferences = PreferencesStore()
    let timer: PomodoroTimer
    let stats = StatisticsStore()
    let notifications: NotificationManager
    let sound: SoundPlayer
    private var cancellables = Set<AnyCancellable>()

    init() {
        timer = PomodoroTimer(preferences: preferences)
        notifications = NotificationManager(preferences: preferences)
        sound = SoundPlayer(preferences: preferences)

        let nc = NotificationCenter.default
        nc.publisher(for: .shortcutToggle).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.timer.startOrPause() }.store(in: &cancellables)
        nc.publisher(for: .shortcutSkip).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.timer.skip() }.store(in: &cancellables)
        nc.publisher(for: .shortcutReset).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.timer.reset() }.store(in: &cancellables)
        nc.publisher(for: .pomodoroPhaseCompleted).receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                // Use the phase from userInfo — it's the phase that JUST completed
                let completedPhase = (notification.userInfo?["phase"] as? TimerPhase) ?? self.timer.phase
                if case .focus = completedPhase {
                    self.stats.recordPomodoro(seconds: self.preferences.focusDuration * 60)
                }
                self.notifications.notifyPhaseCompleted(phase: completedPhase, focusSeconds: self.stats.todayStats.totalFocusSeconds)
                self.sound.playComplete()
            }.store(in: &cancellables)
        nc.publisher(for: .pomodoroTick).receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.sound.playTick() }.store(in: &cancellables)
        nc.publisher(for: UserDefaults.didChangeNotification).receive(on: DispatchQueue.main)
            .compactMap { [weak self] _ in self?.preferences.launchAtLogin }.removeDuplicates().dropFirst()
            .sink { enabled in
                do {
                    if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                } catch { print("SMAppService: \(error)") }
            }.store(in: &cancellables)
    }
}

// MARK: - App Entry

@main
struct PomodoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            DropdownPanel(timer: state.timer, stats: state.stats)
        } label: {
            TimerLabel(timer: state.timer)
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var shortcutMonitor: Any?
    private weak var prefsWindow: NSWindow?
    private let preferences = PreferencesStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Local shortcut monitor — works without accessibility permissions
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleShortcutEvent(event)
            return event
        }

        // Global shortcut monitor — requires accessibility permission
        shortcutMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            self.handleShortcutEvent(event)
        }

        // Listen for preferences open from dropdown
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPreferences),
            name: .openPreferences,
            object: nil
        )
    }

    private func handleShortcutEvent(_ event: NSEvent) {
        guard isCtrlOptCmd(event) else { return }
        switch event.keyCode {
        case 35:  // P — toggle
            NotificationCenter.default.post(name: .shortcutToggle, object: nil)
        case 1:   // S — skip (RightArrow was intercepted by system)
            NotificationCenter.default.post(name: .shortcutSkip, object: nil)
        case 15:  // R — reset
            NotificationCenter.default.post(name: .shortcutReset, object: nil)
        default: break
        }
    }

    @objc private func showPreferences() {
        if let existing = prefsWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 640),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = L10n.tr("preferences_title")
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.contentView = NSHostingView(
            rootView: PreferencesView(preferences: preferences)
                .frame(width: 460, height: 640)
                .tint(.blue)
        )
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        prefsWindow = window
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        prefsWindow = nil
        return false // Don't actually close — just hide
    }

    private func isCtrlOptCmd(_ event: NSEvent) -> Bool {
        event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.control, .option, .command]
    }
}
