import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesStore
    @AppStorage("prefs.language") private var language: String = "auto"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                timerSection
                Divider().padding(.horizontal, 16)
                behaviorSection
                Divider().padding(.horizontal, 16)
                notificationSection
                Divider().padding(.horizontal, 16)
                appearanceSection
                Divider().padding(.horizontal, 16)
                shortcutsSection
                Divider().padding(.horizontal, 16)
                languageSection
                Divider().padding(.horizontal, 16)
                aboutSection
            }
            .padding(.vertical, 8)
        }
        .frame(width: 420, height: 520)
    }

    // MARK: - Timer

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("timer"))
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Behavior

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("behavior"))
            Toggle(L10n.tr("auto_start_next"), isOn: $preferences.autoStartNext)
            Toggle(L10n.tr("launch_at_login"), isOn: $preferences.launchAtLogin)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("notifications"))
            labeledPicker(L10n.tr("notification_mode"), selection: $preferences.notificationModeRaw) {
                ForEach(PreferencesStore.NotificationMode.allCases, id: \.rawValue) { mode in
                    Text(mode.label).tag(mode.rawValue)
                }
            }
            Toggle(L10n.tr("tick_enabled"), isOn: $preferences.tickEnabled)
            if preferences.tickEnabled {
                HStack {
                    Picker(L10n.tr("tick_sound"), selection: $preferences.tickSound) {
                        ForEach(SoundPlayer.availableSounds, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    Button(action: { SoundPlayer.playPreview(named: preferences.tickSound) }) {
                        Image(systemName: "play.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(L10n.tr("tick_description"))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("appearance"))
            labeledPicker(L10n.tr("display_mode"), selection: $preferences.displayMode) {
                ForEach(PreferencesStore.DisplayMode.allCases, id: \.rawValue) { mode in
                    Text(mode.label).tag(mode.rawValue)
                }
            }
            Text(displayPreview)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var displayPreview: String {
        switch PreferencesStore.DisplayMode(rawValue: preferences.displayMode) ?? .timeOnly {
        case .timeOnly:     return L10n.tr("example_time_only")
        case .timeWithIcon: return L10n.tr("example_time_icon")
        }
    }

    // MARK: - Shortcuts

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("shortcuts"))
            shortcutRow(L10n.tr("shortcut_toggle"), "⌃ ⌥ ⌘ P")
            shortcutRow(L10n.tr("shortcut_skip"), "⌃ ⌥ ⌘ S")
            shortcutRow(L10n.tr("shortcut_reset"), "⌃ ⌥ ⌘ R")
            Text(L10n.tr("accessibility_hint"))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func shortcutRow(_ label: String, _ key: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(key)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Language

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(L10n.tr("language"))
            Picker(L10n.tr("language"), selection: $language) {
                ForEach(L10n.supportedLanguages, id: \.code) { lang in
                    Text(lang.name).tag(lang.code)
                }
            }
            Text(L10n.tr("language_hint"))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            sectionHeader(L10n.tr("about"))
            Text("PomodoroNotch v1.0.0")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text("© 2026 raymondjxj")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }

    private func labeledPicker<Content: View>(_ label: String, selection: Binding<some Hashable>, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: selection) { content() }
                .labelsHidden()
                .frame(width: 160)
                .id(language) // force rebuild picker options on language change
        }
    }
}
