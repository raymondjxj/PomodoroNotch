import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences: PreferencesStore
    @AppStorage("prefs.language") private var language: String = "auto"

    var body: some View {
        Form {
            Section {
                Picker(L10n.tr("focus_duration"), selection: $preferences.focusDuration) {
                    ForEach([1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                .id(language)
                Picker(L10n.tr("short_break_duration"), selection: $preferences.shortBreakDuration) {
                    ForEach([1, 3, 5, 10, 15, 20, 25, 30], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                .id(language)
                Picker(L10n.tr("long_break_duration"), selection: $preferences.longBreakDuration) {
                    ForEach([5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { m in
                        Text("\(m) \(L10n.tr("minutes_unit"))").tag(m)
                    }
                }
                .id(language)
                Picker(L10n.tr("long_break_interval"), selection: $preferences.longBreakInterval) {
                    ForEach(2...6, id: \.self) { n in
                        Text(String(format: L10n.tr("every_n_pomodoros"), n)).tag(n)
                    }
                }
                .id(language)
            } header: { SectionLabel(L10n.tr("timer"), "timer") }

            Section {
                Toggle(L10n.tr("auto_start_next"), isOn: $preferences.autoStartNext).toggleStyle(.switch)
                Toggle(L10n.tr("launch_at_login"), isOn: $preferences.launchAtLogin).toggleStyle(.switch)
            } header: { SectionLabel(L10n.tr("behavior"), "gearshape.arrow.triangle.2.circlepath") }

            Section {
                Picker(L10n.tr("notification_mode"), selection: $preferences.notificationModeRaw) {
                    Text(L10n.tr("sound_banner")).tag("soundAndBanner")
                    Text(L10n.tr("sound_only")).tag("soundOnly")
                    Text(L10n.tr("banner_only")).tag("bannerOnly")
                    Text(L10n.tr("off")).tag("off")
                }
                .id(language)
                Toggle(L10n.tr("tick_enabled"), isOn: $preferences.tickEnabled).toggleStyle(.switch)
                if preferences.tickEnabled {
                    HStack {
                        Picker(L10n.tr("tick_sound"), selection: $preferences.tickSound) {
                            ForEach(SoundPlayer.availableSounds, id: \.self) { Text($0).tag($0) }
                        }
                        .id(language)
                        Button(action: { SoundPlayer.playPreview(named: preferences.tickSound) }) {
                            Image(systemName: "play.circle.fill").font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: { SectionLabel(L10n.tr("notifications"), "bell") }
            footer: { Text(L10n.tr("tick_description")).font(.system(size: 11)).foregroundColor(.secondary) }

            Section {
                Picker(L10n.tr("display_mode"), selection: $preferences.displayMode) {
                    Text(L10n.tr("time_only")).tag("timeOnly")
                    Text(L10n.tr("time_with_icon")).tag("timeWithIcon")
                }
                .id(language)
            } header: { SectionLabel(L10n.tr("appearance"), "paintpalette") }
            footer: { Text(displayPreview).font(.system(size: 11)).foregroundColor(.secondary) }

            Section {
                Picker(L10n.tr("language"), selection: $language) {
                    ForEach(L10n.supportedLanguages, id: \.code) { lang in Text(lang.name).tag(lang.code) }
                }
                .id(language)
            } header: { SectionLabel(L10n.tr("language"), "globe") }

            Section {
                shortcutRow(L10n.tr("shortcut_toggle"), "⌃ ⌥ ⌘ P")
                shortcutRow(L10n.tr("shortcut_skip"), "⌃ ⌥ ⌘ S")
                shortcutRow(L10n.tr("shortcut_reset"), "⌃ ⌥ ⌘ R")
            } header: { SectionLabel(L10n.tr("shortcuts"), "command") }
            footer: { Text(L10n.tr("accessibility_hint")).font(.system(size: 11)).foregroundColor(.secondary) }

            Section {
                HStack { Text("PomodoroNotch").font(.system(size: 12)).foregroundColor(.secondary); Spacer(); Text("v1.0.0").font(.system(size: 12)).foregroundColor(.secondary) }
            } header: { SectionLabel(L10n.tr("about"), "info.circle") }
        }
        .formStyle(.grouped)
        .frame(minWidth: 440, idealWidth: 460, minHeight: 560, idealHeight: 600)
    }

    private func shortcutRow(_ label: String, _ keys: String) -> some View {
        HStack { Text(label); Spacer(); Text(keys).font(.system(size: 12, design: .monospaced)).foregroundColor(.secondary) }
    }

    private var displayPreview: String {
        let mode = PreferencesStore.DisplayMode(rawValue: preferences.displayMode) ?? .timeOnly
        return mode == .timeWithIcon ? L10n.tr("example_time_icon") : L10n.tr("example_time_only")
    }
}

private struct SectionLabel: View {
    let title: String; let icon: String
    init(_ t: String, _ i: String) { title = t; icon = i }
    var body: some View {
        Label(title, systemImage: icon).font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
    }
}
