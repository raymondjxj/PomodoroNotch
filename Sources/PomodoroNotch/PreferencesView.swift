import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesStore
    @AppStorage("prefs.language") private var language: String = "auto"

    var body: some View {
        Form {
            // MARK: Timer
            Section {
                labeledPicker(L10n.tr("focus_duration"), selection: $preferences.focusDuration) {
                    ForEach([1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                labeledPicker(L10n.tr("short_break_duration"), selection: $preferences.shortBreakDuration) {
                    ForEach([1, 3, 5, 10, 15, 20, 25, 30], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                labeledPicker(L10n.tr("long_break_duration"), selection: $preferences.longBreakDuration) {
                    ForEach([5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                labeledPicker(L10n.tr("long_break_interval"), selection: $preferences.longBreakInterval) {
                    ForEach(2...6, id: \.self) { n in
                        Text(String(format: L10n.tr("every_n_pomodoros"), n)).tag(n)
                    }
                }
            } header: {
                sectionLabel(L10n.tr("timer"), "timer")
            }

            // MARK: Behavior
            Section {
                Toggle(L10n.tr("auto_start_next"), isOn: $preferences.autoStartNext)
                    .toggleStyle(.switch)
                Toggle(L10n.tr("launch_at_login"), isOn: $preferences.launchAtLogin)
                    .toggleStyle(.switch)
            } header: {
                sectionLabel(L10n.tr("behavior"), "gearshape.arrow.triangle.2.circlepath")
            }

            // MARK: Notifications
            Section {
                labeledPicker(L10n.tr("notification_mode"), selection: $preferences.notificationModeRaw) {
                    ForEach(PreferencesStore.NotificationMode.allCases, id: \.rawValue) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                Toggle(L10n.tr("tick_enabled"), isOn: $preferences.tickEnabled)
                    .toggleStyle(.switch)
                if preferences.tickEnabled {
                    HStack {
                        Picker(L10n.tr("tick_sound"), selection: $preferences.tickSound) {
                            ForEach(SoundPlayer.availableSounds, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .id(language)
                        Button(action: { SoundPlayer.playPreview(named: preferences.tickSound) }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help(L10n.tr("tick_description"))
                    }
                }
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(L10n.tr("tick_description"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            } header: {
                sectionLabel(L10n.tr("notifications"), "bell")
            }

            // MARK: Appearance
            Section {
                labeledPicker(L10n.tr("display_mode"), selection: $preferences.displayMode) {
                    ForEach(PreferencesStore.DisplayMode.allCases, id: \.rawValue) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                HStack(spacing: 6) {
                    Image(systemName: "eye")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(displayPreview)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            } header: {
                sectionLabel(L10n.tr("appearance"), "paintpalette")
            }

            // MARK: Language
            Section {
                Picker(L10n.tr("language"), selection: $language) {
                    ForEach(L10n.supportedLanguages, id: \.code) { lang in
                        Text(lang.name).tag(lang.code)
                    }
                }
                .id(language)
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(L10n.tr("language_hint"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            } header: {
                sectionLabel(L10n.tr("language"), "globe")
            }

            // MARK: Shortcuts
            Section {
                shortcutRow(L10n.tr("shortcut_toggle"), "⌃ ⌥ ⌘ P")
                shortcutRow(L10n.tr("shortcut_skip"), "⌃ ⌥ ⌘ S")
                shortcutRow(L10n.tr("shortcut_reset"), "⌃ ⌥ ⌘ R")
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(L10n.tr("accessibility_hint"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            } header: {
                sectionLabel(L10n.tr("shortcuts"), "command")
            }

            // MARK: About
            Section {
                HStack {
                    Text("PomodoroNotch")
                    Spacer()
                    Text("v1.0.0")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("© 2026 raymondjxj")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } header: {
                sectionLabel(L10n.tr("about"), "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 600)
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, _ icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
    }

    private func labeledPicker<Content: View>(_ label: String, selection: Binding<some Hashable>, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            Picker("", selection: selection) { content() }
                .labelsHidden()
                .id(language)
        }
    }

    private func shortcutRow(_ label: String, _ keys: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }

    private var displayPreview: String {
        switch PreferencesStore.DisplayMode(rawValue: preferences.displayMode) ?? .timeOnly {
        case .timeOnly:     return L10n.tr("example_time_only")
        case .timeWithIcon: return L10n.tr("example_time_icon")
        }
    }
}
