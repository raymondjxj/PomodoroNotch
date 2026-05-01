# 🍅 PomodoroNotch

**Der Pomodoro-Timer, der nicht stört.** In der Menüleiste. Tastaturgesteuert. Unter 5 MB RAM. Keine Konten, keine Cloud.

## Warum noch eine Pomodoro-App?

Die meisten Pomodoro-Timer sind entweder aufgeblähte Electron-Apps (500 MB RAM, Abos) oder Web-Tools, die in Browsertabs verschwinden. Ein guter Timer sollte unsichtbar sein, bis man ihn braucht – und dann sofort reagieren.

PomodoroNotch ist anders: native SwiftUI-Menüleisten-App, `⌃⌥⌘P` globaler Shortcut, null Netzwerkzugriffe, 7 Quelldateien mit ~1.000 Zeilen.

## Menüleisten-Status

| Phase | Anzeige | Farbe |
|-------|---------|-------|
| Inaktiv | `·` | Grau, transparent |
| Fokus | `24:59` oder `🍅 25m` | Orange #FF6B35 |
| Kurze Pause | `☕ 5m` | Grün #34C759 |
| Lange Pause | `🛋 15m` | Grün #34C759 |
| Pausiert | Pulsierende Animation | Grau #8E8E93 |

## Installation

DMG von [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest) herunterladen.
```bash
git clone https://github.com/raymondjxj/PomodoroNotch.git && cd PomodoroNotch && make run
```

## Globale Tastenkürzel

| Tasten | Aktion |
|--------|--------|
| `⌃⌥⌘P` | Start / Pause / Fortsetzen |
| `⌃⌥⌘S` | Aktuelle Phase überspringen |
| `⌃⌥⌘R` | Zurücksetzen |

Erfordert Eingabehilfen-Berechtigung in den Systemeinstellungen.

## Funktionen

- **Dropdown-Panel**: 32pt Countdown, Steuerung, Tagesstatistik, Wochenübersicht
- **12 Tick-Geräusche**: mit Live-Vorschau in den Einstellungen
- **Benachrichtigungen**: Ton+Banner / Nur Ton / Nur Banner / Aus
- **Statistiken**: lokal als JSON gespeichert
- **Zustandspersistenz**: bei jedem Phasenwechsel gespeichert, nach Neustart exakt wiederhergestellt
- **11 Sprachen**: automatische Erkennung oder manuelle Auswahl

## Architektur

7 Swift-Dateien, null externe Abhängigkeiten. Rekursives Enum `TimerPhase` für die Zustandsmaschine, `NotificationCenter` zur Entkopplung, `@AppStorage` für Einstellungen.

## FAQ

**Menüleisten-Symbol fehlt?** macOS 26+: Systemeinstellungen → Kontrollzentrum → PomodoroNotch aktivieren.

**Tastenkürzel funktionieren nicht?** Eingabehilfen-Berechtigung prüfen.

MIT © [raymondjxj](https://github.com/raymondjxj)
