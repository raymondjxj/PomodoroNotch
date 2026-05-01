# 🍅 PomodoroNotch

**Le minuteur Pomodoro qui ne vous dérange pas.** Dans la barre de menus. Piloté au clavier. Moins de 5 Mo de RAM. Aucun compte, aucun cloud.

## Pourquoi une autre app Pomodoro ?

La plupart des minuteurs Pomodoro sont soit des apps Electron gonflées (500 Mo de RAM, abonnements), soit des outils web perdus dans vos onglets. Un bon minuteur doit être invisible jusqu'au moment où vous en avez besoin, puis instantané.

PomodoroNotch est différent : natif macOS (SwiftUI + AppKit), `⌃⌥⌘P` global, zéro requête réseau, 7 fichiers source (~1 000 lignes).

## États de la barre de menus

| Phase | Affichage | Couleur |
|-------|-----------|---------|
| Inactif | `·` | Gris transparent |
| Focus | `24:59` ou `🍅 25m` | Orange #FF6B35 |
| Pause courte | `☕ 5m` | Vert #34C759 |
| Pause longue | `🛋 15m` | Vert #34C759 |
| En pause | Animation pulsée | Gris #8E8E93 |

## Installation

Téléchargez le DMG depuis [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest).
```bash
git clone https://github.com/raymondjxj/PomodoroNotch.git && cd PomodoroNotch && make run
```

## Raccourcis globaux

| Raccourci | Action |
|-----------|--------|
| `⌃⌥⌘P` | Démarrer / Pause / Reprendre |
| `⌃⌥⌘S` | Passer la phase actuelle |
| `⌃⌥⌘R` | Réinitialiser |

Nécessite l'autorisation Accessibilité dans Réglages Système.

## Cycle Pomodoro

Inactif → Focus (25 min par défaut) → Pause courte (5 min) → Focus → ... → toutes les 4 sessions : Pause longue (15 min). Toutes les durées sont configurables. Le minuteur se met en pause quand le Mac dort et recalcule le temps écoulé au réveil.

## Fonctionnalités

- **Panneau déroulant** : grand minuteur 32 pt, contrôles, statistiques du jour, graphique hebdomadaire
- **12 sons tic-tac** : aperçu en direct dans les préférences
- **Notifications** : son + bannière / son seul / bannière seule / désactivé
- **Statistiques** : stockées en local (JSON)
- **Persistance** : état sauvegardé à chaque changement de phase
- **11 langues** : détection automatique ou sélection manuelle

## Architecture

7 fichiers Swift, zéro dépendance externe. Enum récursive `TimerPhase` pour la machine d'état, `NotificationCenter` pour le découplage, `@AppStorage` pour les préférences.

## FAQ

**L'icône n'apparaît pas ?** macOS 26+ : Réglages Système → Centre de contrôle → activez PomodoroNotch.

**Raccourcis inactifs ?** Vérifiez l'autorisation Accessibilité.

MIT © [raymondjxj](https://github.com/raymondjxj)
