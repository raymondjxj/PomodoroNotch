import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        TabView {
            TimerTab(preferences: preferences)
                .tabItem { Label("计时", systemImage: "timer") }
            AppearanceTab(preferences: preferences)
                .tabItem { Label("外观", systemImage: "paintpalette") }
            NotificationsTab(preferences: preferences)
                .tabItem { Label("通知", systemImage: "bell") }
            ShortcutsTab()
                .tabItem { Label("快捷键", systemImage: "command") }
        }
        .frame(width: 420, height: 440)
        .tint(.blue)
    }
}

// MARK: - Timer Tab

private struct TimerTab: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        Form {
            Section("计时") {
                Picker("专注时长", selection: $preferences.focusDuration) {
                    ForEach([1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120], id: \.self) { m in
                        Text("\(m) 分钟").tag(m)
                    }
                }
                Picker("短休息时长", selection: $preferences.shortBreakDuration) {
                    ForEach([1, 3, 5, 10, 15, 20, 25, 30], id: \.self) { m in
                        Text("\(m) 分钟").tag(m)
                    }
                }
                Picker("长休息时长", selection: $preferences.longBreakDuration) {
                    ForEach([5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { m in
                        Text("\(m) 分钟").tag(m)
                    }
                }
                Picker("长休息间隔", selection: $preferences.longBreakInterval) {
                    ForEach(2...6, id: \.self) { n in
                        Text("每 \(n) 个番茄").tag(n)
                    }
                }
            }
            Section("行为") {
                Toggle("自动开始下一阶段", isOn: $preferences.autoStartNext)
                    .toggleStyle(.switch)
                Toggle("登录时自动启动", isOn: $preferences.launchAtLogin)
                    .toggleStyle(.switch)
            }
        }
        .formStyle(.grouped)
    }

}

// MARK: - Appearance Tab

private struct AppearanceTab: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        Form {
            Section("菜单栏显示") {
                Picker("显示模式", selection: $preferences.displayMode) {
                    ForEach(PreferencesStore.DisplayMode.allCases, id: \.rawValue) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                Text(previewDescription)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var previewDescription: String {
        switch PreferencesStore.DisplayMode(rawValue: preferences.displayMode) ?? .timeOnly {
        case .timeOnly:     return "示例: 24:59"
        case .timeWithIcon: return "示例: 🍅 24:59"
        }
    }
}

// MARK: - Notifications Tab

private struct NotificationsTab: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        Form {
            Section("通知方式") {
                Picker("通知方式", selection: $preferences.notificationModeRaw) {
                    ForEach(PreferencesStore.NotificationMode.allCases, id: \.rawValue) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
            }
            Section("音效") {
                Toggle("最后 60 秒 tick 音效", isOn: $preferences.tickEnabled)
                    .toggleStyle(.switch)
                if preferences.tickEnabled {
                    HStack {
                        Picker("提示音", selection: $preferences.tickSound) {
                            ForEach(SoundPlayer.availableSounds, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        Button(action: {
                            SoundPlayer.playPreview(named: preferences.tickSound)
                        }) {
                            Image(systemName: "play.circle")
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("倒计时最后 60 秒，每秒播放短促提示音")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Shortcuts Tab

private struct ShortcutsTab: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("开始 / 暂停") {
                    Text("⌃ ⌥ ⌘ P")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                LabeledContent("跳过") {
                    Text("⌃ ⌥ ⌘ S")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                LabeledContent("重置") {
                    Text("⌃ ⌥ ⌘ R")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("全局快捷键")
            } footer: {
                Text("需要辅助功能权限才能使用全局快捷键。可在 系统设置 → 隐私与安全性 → 辅助功能 中授权。")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
