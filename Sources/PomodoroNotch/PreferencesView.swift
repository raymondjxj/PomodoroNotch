import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesStore
    @AppStorage("prefs.language") private var language: String = "auto"

    var body: some View {
        Form {
            // MARK: Timer
            Section { sectionHeader(L10n.tr("timer"), "timer") }
            pickerRow(L10n.tr("focus_duration"), $preferences.focusDuration,
                [1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120]) { "\($0) \(L10n.tr("minutes_unit"))" }
            pickerRow(L10n.tr("short_break_duration"), $preferences.shortBreakDuration,
                [1, 3, 5, 10, 15, 20, 25, 30]) { "\($0) \(L10n.tr("minutes_unit"))" }
            pickerRow(L10n.tr("long_break_duration"), $preferences.longBreakDuration,
                [5, 10, 15, 20, 25, 30, 45, 60]) { "\($0) \(L10n.tr("minutes_unit"))" }
            pickerRow(L10n.tr("long_break_interval"), $preferences.longBreakInterval,
                Array(2...6)) { String(format: L10n.tr("every_n_pomodoros"), $0) }

            // MARK: Behavior
            Section { sectionHeader(L10n.tr("behavior"), "gearshape.arrow.triangle.2.circlepath") }
            toggleRow(L10n.tr("auto_start_next"), $preferences.autoStartNext)
            toggleRow(L10n.tr("launch_at_login"), $preferences.launchAtLogin)

            // MARK: Notifications
            Section { sectionHeader(L10n.tr("notifications"), "bell") }
            pickerRow(L10n.tr("notification_mode"), $preferences.notificationModeRaw,
                PreferencesStore.NotificationMode.allCases.map(\.rawValue)) { code in
                PreferencesStore.NotificationMode(rawValue: code)?.label ?? code
            }
            toggleRow(L10n.tr("tick_enabled"), $preferences.tickEnabled)
            if preferences.tickEnabled {
                HStack(spacing: 8) {
                    Picker(L10n.tr("tick_sound"), selection: $preferences.tickSound) {
                        ForEach(SoundPlayer.availableSounds, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .id(language)
                    .labelsHidden()
                    Button(action: { SoundPlayer.playPreview(named: preferences.tickSound) }) {
                        Image(systemName: "play.circle.fill").font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            footnote(tickDescription)

            // MARK: Appearance
            Section { sectionHeader(L10n.tr("appearance"), "paintpalette") }
            pickerRow(L10n.tr("display_mode"), $preferences.displayMode,
                PreferencesStore.DisplayMode.allCases.map(\.rawValue)) { code in
                PreferencesStore.DisplayMode(rawValue: code)?.label ?? code
            }
            footnote(L10n.tr("example_\(preferences.displayMode == "timeWithIcon" ? "time_icon" : "time_only")"))

            // MARK: Language
            Section { sectionHeader(L10n.tr("language"), "globe") }
            pickerRow(nil, $language, L10n.supportedLanguages.map(\.code)) { code in
                L10n.supportedLanguages.first(where: { $0.code == code })?.name ?? code
            }
            footnote(L10n.tr("language_hint"))

            // MARK: Shortcuts
            Section { sectionHeader(L10n.tr("shortcuts"), "command") }
            shortcutRow(L10n.tr("shortcut_toggle"), "⌃  ⌥  ⌘  P")
            shortcutRow(L10n.tr("shortcut_skip"), "⌃  ⌥  ⌘  S")
            shortcutRow(L10n.tr("shortcut_reset"), "⌃  ⌥  ⌘  R")
            footnote(L10n.tr("accessibility_hint"))

            // MARK: About
            Section { sectionHeader(L10n.tr("about"), "info.circle") }
            infoRow("PomodoroNotch", "v1.0.0")
            infoRow("© 2026 raymondjxj", "")
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 620)
        .scrollDisabled(false)
    }

    // MARK: - Row Components (uniform height = 28pt)

    private func sectionHeader(_ title: String, _ icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.bottom, -4)
    }

    private func toggleRow(_ label: String, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) { Text(label) }
            .toggleStyle(.switch)
    }

    private func shortcutRow(_ label: String, _ keys: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(keys)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(.secondary)
            if !value.isEmpty {
                Spacer()
                Text(value).font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
    }

    private func pickerRow<T: Hashable>(_ label: String?, _ binding: Binding<T>, _ items: [T], _ title: @escaping (T) -> String) -> some View {
        Picker(selection: binding) {
            ForEach(items, id: \.self) { item in
                Text(title(item)).tag(item)
            }
        } label: {
            if let label { Text(label) }
        }
        .id(language)
    }

    private func footnote(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    private var tickDescription: String {
        if preferences.tickEnabled {
            return L10n.tr("tick_description")
        }
        return L10n.tr("tick_description")
    }
}
