# 🍅 PomodoroNotch
**Il timer Pomodoro che non ti disturba.** Nella barra dei menu. Pilotato da tastiera. Meno di 5 MB di RAM. Nessun account, nessun cloud.

## Perché un'altra app Pomodoro?
La maggior parte dei timer Pomodoro sono app Electron pesanti (500 MB di RAM, abbonamenti) o strumenti web persi nelle schede del browser. Un buon timer dovrebbe essere invisibile fino al momento del bisogno, poi immediato. PomodoroNotch è diverso: nativo SwiftUI, `⌃⌥⌘P` globale, zero richieste di rete, 7 file sorgente (~1.000 righe).

## Stati della barra dei menu
| Fase | Display | Colore |
|------|---------|--------|
| Inattivo | `·` | Grigio trasparente |
| Focus | `24:59` o `🍅 25m` | Arancione #FF6B35 |
| Pausa breve | `☕ 5m` | Verde #34C759 |
| Pausa lunga | `🛋 15m` | Verde #34C759 |
| In pausa | Animazione pulsante | Grigio #8E8E93 |

## Installazione
Scarica il DMG da [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest).

## Scorciatoie globali
| Tasti | Azione |
|-------|--------|
| `⌃⌥⌘P` | Avvia / Pausa / Riprendi |
| `⌃⌥⌘S` | Salta fase corrente |
| `⌃⌥⌘R` | Reimposta |

Richiede il permesso Accessibilità in Impostazioni di Sistema.

## Funzionalità
- **Pannello a discesa**: countdown 32pt, controlli, statistiche del giorno, grafico settimanale
- **12 suoni ticchettio**: anteprima dal vivo nelle preferenze
- **Notifiche**: audio+banner / solo audio / solo banner / disattivato
- **Statistiche**: salvate in locale (JSON)
- **Persistenza stato**: salvato ad ogni cambio fase, ripristino esatto dopo il riavvio
- **11 lingue**: rilevamento automatico o selezione manuale

## Architettura
7 file Swift, zero dipendenze esterne. Enum ricorsivo `TimerPhase` per la macchina a stati, `NotificationCenter` per il disaccoppiamento, `@AppStorage` per le impostazioni.

## FAQ
**L'icona non appare?** macOS 26+: Impostazioni di Sistema → Centro di Controllo → attiva PomodoroNotch.
**Scorciatoie non funzionanti?** Verifica il permesso Accessibilità.
MIT © [raymondjxj](https://github.com/raymondjxj)
