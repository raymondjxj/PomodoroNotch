<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple">
  <img alt="macOS 14.0+" src="https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple">
</picture>
<a href="https://github.com/raymondjxj/PomodoroNotch/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/raymondjxj/PomodoroNotch?color=%23FF6B35&label=latest"></a>
<a href="LICENSE"><img alt="License MIT" src="https://img.shields.io/badge/license-MIT-green"></a>
<a href="https://github.com/raymondjxj/PomodoroNotch/actions"><img alt="CI" src="https://github.com/raymondjxj/PomodoroNotch/actions/workflows/build-dmg.yml/badge.svg"></a>

# 🍅 番茄时钟 · PomodoroNotch

**The Pomodoro timer that doesn't get in your way.** Lives in the menu bar. Keyboard-driven. Uses less than 5MB of RAM. No accounts, no cloud, no distractions.

<img alt="主界面" src="Assets/主界面.png" width="600">

---

## Why another Pomodoro app?

Most Pomodoro timers fall into two camps:

- **Bloated Electron apps** — 500MB RAM, splash screens, account sign-ups, "pro" subscriptions
- **Web-based tools** — require a browser tab, get lost among dozens of open tabs, can't send system notifications when buried

Neither respects your focus. A timer should be invisible until you need it, instant when you do, and never steal attention from the work itself.

**PomodoroNotch** takes a different approach:

- **Always visible, never intrusive** — the countdown sits in your menu bar. One glance, no clicks.
- **Keyboard-first** — `⌃⌥⌘P` starts or pauses from any app. No cursor hunting.
- **Native, not cross-platform** — SwiftUI + AppKit. SF Symbols. System sounds. Feels like a built-in macOS feature.
- **Zero network access** — no analytics, no sync, no "cloud." Your focus data stays on your machine.
- **7 source files, ~1,000 lines of code** — you can read the entire codebase in 15 minutes.

---

## What it looks like

<p align="center">
  <img alt="主界面" src="Assets/主界面.png" width="600"><br>
  <em>Click the timer to open the dropdown panel — large countdown, one-tap controls, today's stats, weekly chart.</em>
</p>

<p align="center">
  <img alt="偏好设置" src="Assets/偏好设置.png" width="400"><br>
  <em>Preferences: configure durations, notifications, 12 tick sounds (with live preview), shortcuts, and language.</em>
</p>

### Menu bar states

| Phase | Display | Color |
|-------|---------|-------|
| Idle | `·` (subtle dot) | Gray, nearly transparent |
| Focusing | `24:59` or `🍅 25m` | `#FF6B35` warm orange |
| Short break | `04:32` or `☕ 5m` | `#34C759` green |
| Long break | `14:32` or `🛋 15m` | `#34C759` green |
| Paused | Pulsing countdown | `#8E8E93` gray |

The display mode is configurable — bare numbers (`24:59`) or icon + remaining minutes (`🍅 25m`).

---

## Installation

### Recommended: Download DMG

Go to [**Releases**](https://github.com/raymondjxj/PomodoroNotch/releases/latest) → download the latest `.dmg` → drag **番茄时钟** into `/Applications`.

The DMG is built automatically by GitHub Actions on every version tag. It's ad-hoc signed — macOS will ask you to confirm on first launch, then never again.

### Build from source

```bash
git clone https://github.com/raymondjxj/PomodoroNotch.git
cd PomodoroNotch
make run          # builds + launches in one command
```

Requires macOS 14.0+ and Xcode 16+ (or Command Line Tools with Swift 6).

### Via Homebrew (planned)

```bash
brew install --cask pomodoro-notch
```

---

## Keyboard Shortcuts

All shortcuts work **globally** — you don't need to switch back to the app first.

| Shortcut | Action | When |
|----------|--------|------|
| `⌃` `⌥` `⌘` `P` | Start / Pause / Resume | Always |
| `⌃` `⌥` `⌘` `S` | Skip to next phase | Timer running or paused |
| `⌃` `⌥` `⌘` `R` | Reset timer to idle | Always |

New to macOS: you'll need to grant **Accessibility** permission once in *System Settings → Privacy & Security → Accessibility* for global shortcuts to work. The local shortcut monitor works without permissions when PomodoroNotch is the active app.

The modifier combination (`⌃⌥⌘`) was chosen deliberately — it almost never conflicts with other apps or system shortcuts.

---

## How the Pomodoro Cycle Works

```
IDLE
  └─ Click "Start" or press ⌃⌥⌘P
       ↓
FOCUS (default 25 min)  ←──────────────────────┐
  └─ Timer ends → notification + sound           │
       ↓                                         │
SHORT BREAK (default 5 min)                      │
  └─ Timer ends → notification                    │
       ↓                                         │
FOCUS (25 min)                                   │
  └─ After every 4th focus → LONG BREAK (15 min) │
       ↓                                         │
FOCUS ... ──────────────────────────────────────┘
```

Configurable in Preferences:
- **Focus duration**: 1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, or 120 minutes
- **Short break**: 1–30 minutes
- **Long break**: 5–60 minutes
- **Long break interval**: every 2–6 pomodoros
- **Auto-start**: next phase begins automatically, or waits for your manual confirmation

When your Mac sleeps, the timer pauses. When it wakes, the elapsed time is recalculated so you never lose track.

---

## Features in Detail

### Dropdown Panel
Click the menu bar timer to reveal a panel with:
- **Large countdown** — 32pt monospaced digits, impossible to misread
- **One-tap controls** — Play/Pause and Skip, each labeled with its keyboard shortcut
- **Today's stats** — pomodoros completed and total focus time
- **Weekly bar chart** — Monday through Sunday, visual at a glance

### Tick Sounds (Last 60 Seconds)
A subtle audio cue each second during the final minute of focus — like a physical kitchen timer, but gentler. 12 system sounds to choose from: Tink, Pop, Blow, Bottle, Frog, Funk, Hero, Morse, Ping, Purr, Sosumi, Submarine. Each one has a live preview button in Preferences.

### Notifications
Configurable per-completion:
- Sound + banner (default)
- Sound only
- Banner only
- Completely silent

Notifications respect Do Not Disturb for banners, but always play the completion sound — because sometimes you're in the zone and need that audio cue to remember to stand up.

### Statistics
Daily and weekly data stored locally in `~/Library/Application Support/PomodoroNotch/stats.json`. No cloud, no sync, no uploads. Just a JSON file you can read, delete, or back up however you like.

### State Persistence
The timer state is saved to `UserDefaults` on every phase change. If the app crashes (it shouldn't, but software is software) or you reboot your Mac, the timer restores to exactly where you left it — including the correct remaining seconds calculated from when the phase started.

### Language Support
The UI auto-detects your system language, or you can manually choose from 11 languages in Preferences → Language:
**简体中文 · English · 繁體中文 · Français · 日本語 · Deutsch · Italiano · Español · Português · Bahasa Indonesia · Русский**

---

## Architecture

For contributors and the curious:

```
Sources/PomodoroNotch/
├── App.swift                  # @main entry point, MenuBarExtra scene,
│                              #   TimerLabel, DropdownPanel, AppDelegate
├── PomodoroTimer.swift        # State machine (idle/focus/break/paused),
│                              #   1-second countdown, UserDefaults persistence
├── PreferencesView.swift      # Preferences window — grouped form, 7 sections
├── PreferencesStore.swift     # @AppStorage-backed settings, zero boilerplate
├── StatisticsStore.swift      # Daily/weekly stats, JSON file I/O,
│                              #   in-memory cache with write-through
├── NotificationManager.swift  # UNUserNotificationCenter wrapper
├── SoundPlayer.swift          # NSSound playback, 12-system-sound catalog
└── Localization.swift         # 11-language string dictionary,
                               #   auto-detect + manual override via UserDefaults
```

**Zero external dependencies.** The entire dependency graph is the macOS SDK.

### State Machine

```
        ┌───────┐
   ┌───▶│ IDLE  │◀──reset──┐
   │    └───┬───┘           │
   │   start│               │
   │        ▼               │
   │    ┌───────┐    ┌──────┴──┐
   │    │ FOCUS │◀──▶│ PAUSED  │
   │    └───┬───┘    └─────────┘
   │  end   │
   │        ▼
   │    ┌───────────┐
   │    │   BREAK   │◀──▶ PAUSED
   │    │ (short or │
   │    │  long)    │
   │    └─────┬─────┘
   │     end  │
   └──────────┘
```

`TimerPhase` is a recursive enum: `idle | focus | shortBreak | longBreak | paused(underlying)`. This means pause preserves the exact underlying phase with zero additional state.

### Data Flow

```
NSEvent (keyboard) → AppDelegate → NotificationCenter → AppState observer
  → PomodoroTimer.action() → @Published phase/remainingSeconds
    → TimerLabel re-renders (menu bar)
    → DropdownPanel re-renders (dropdown)
```

Every action flows through `NotificationCenter` as a decoupling layer. The keyboard handler doesn't know about the timer; the timer doesn't know about the menu bar. Each module only depends on the notification names it cares about.

---

## FAQ

### The menu bar item doesn't show up.

On **macOS 26 Tahoe** (and later), third-party menu bar items default to hidden. Go to **System Settings → Control Center**, scroll to the bottom, find "番茄时钟," and set it to "Show in Menu Bar." This is a system-level change Apple introduced in Tahoe — it affects all menu bar apps equally.

### Global keyboard shortcuts don't work.

Two things to check:
1. Grant **Accessibility** permission: *System Settings → Privacy & Security → Accessibility* → add PomodoroNotch.
2. Verify no other app is using `⌃⌥⌘P` / `⌃⌥⌘S` / `⌃⌥⌘R`. The combination is chosen to minimize conflicts, but it's not impossible.

### Why no progress bar / task list / project integration?

By design. PomodoroNotch is a timer, not a project management tool. It does one thing — tracks focus and break intervals — and tries to do it well. If you need task tracking, use it alongside your existing to-do app or notebook.

### Does it work on Intel Macs?

Yes. The DMG is Apple Silicon, but you can build for Intel with `swift build --arch x86_64`.

### What does the data look like?

No data leaves your machine. Stats are stored as a simple JSON file:

```json
[{
  "date": "2026-05-01",
  "completedPomodoros": 5,
  "totalFocusSeconds": 7500
}]
```

Delete it anytime — the app will create a fresh one on the next completed pomodoro.

---

## Internationalization

The app UI supports 11 languages. It auto-detects your system language on first launch; you can override it in Preferences → Language at any time without restarting.

**简体中文 · English · 繁體中文 · Français · 日本語 · Deutsch · Italiano · Español · Português · Bahasa Indonesia · Русский**

README translations: [English](docs/README.en.md) · [繁體中文](docs/README.zh-Hant.md) · [Français](docs/README.fr.md) · [日本語](docs/README.ja.md) · [Deutsch](docs/README.de.md) · [Italiano](docs/README.it.md) · [Español](docs/README.es.md) · [Português](docs/README.pt.md) · [Bahasa Indonesia](docs/README.id.md) · [Русский](docs/README.ru.md)

---

## License

MIT © [raymondjxj](https://github.com/raymondjxj)

---

*If things are not failing, you are not innovating enough.*
