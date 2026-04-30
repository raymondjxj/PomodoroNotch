import SwiftUI

final class PreferencesStore: ObservableObject {
    @AppStorage("prefs.focusDuration") var focusDuration: Int = 25
    @AppStorage("prefs.shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("prefs.longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("prefs.longBreakInterval") var longBreakInterval: Int = 4
    @AppStorage("prefs.autoStartNext") var autoStartNext: Bool = true
    @AppStorage("prefs.tickEnabled") var tickEnabled: Bool = false
    @AppStorage("prefs.tickSound") var tickSound: String = "Tink"
    @AppStorage("prefs.notificationMode") var notificationModeRaw: String = "soundAndBanner"
    @AppStorage("prefs.displayMode") var displayMode: String = "timeOnly"
    @AppStorage("prefs.launchAtLogin") var launchAtLogin: Bool = false

    enum NotificationMode: String, CaseIterable {
        case soundAndBanner, soundOnly, bannerOnly, off
        var label: String {
            switch self {
            case .soundAndBanner: return "声音 + 横幅"
            case .soundOnly:      return "仅声音"
            case .bannerOnly:     return "仅横幅"
            case .off:            return "关闭"
            }
        }
    }

    var notificationMode: NotificationMode {
        NotificationMode(rawValue: notificationModeRaw) ?? .soundAndBanner
    }

    enum DisplayMode: String, CaseIterable {
        case timeOnly, timeWithIcon
        var label: String {
            switch self {
            case .timeOnly:     return "仅计时数字"
            case .timeWithIcon: return "数字 + 图标"
            }
        }
    }
}
