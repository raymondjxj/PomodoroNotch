import UserNotifications

@MainActor
final class NotificationManager: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    private let preferences: PreferencesStore

    init(preferences: PreferencesStore) {
        self.preferences = preferences
        super.init()

        // UNUserNotificationCenter requires an app bundle with a bundle identifier.
        // When running from `swift run` (raw executable), skip notifications.
        guard Bundle.main.bundleIdentifier != nil else {
            print("[PomodoroNotch] No app bundle — notifications disabled.")
            return
        }
        UNUserNotificationCenter.current().delegate = self
        requestPermission()
    }

    func requestPermission() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func notifyPhaseCompleted(phase: TimerPhase, focusSeconds: Int) {
        let mode = preferences.notificationMode
        guard mode != .off, Bundle.main.bundleIdentifier != nil else { return }

        let title: String
        let body: String

        if phase.isWorking {
            title = "番茄完成"
            let minutes = focusSeconds / 60
            body = "已专注 \(minutes) 分钟，休息一下吧"
        } else {
            title = "休息结束"
            body = "准备开始下一个番茄"
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        switch mode {
        case .soundOnly:
            content.sound = .default
        case .bannerOnly:
            content.sound = nil
        case .soundAndBanner:
            content.sound = .default
        case .off:
            return
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // immediate
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let mode = preferences.notificationMode
        var options: UNNotificationPresentationOptions = []
        if mode == .bannerOnly || mode == .soundAndBanner {
            options.insert(.banner)
        }
        if mode == .soundOnly || mode == .soundAndBanner {
            options.insert(.sound)
        }
        completionHandler(options)
    }
}
