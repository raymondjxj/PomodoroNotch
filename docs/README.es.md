# 🍅 PomodoroNotch
**El temporizador Pomodoro que no molesta.** En la barra de menús. Controlado por teclado. Menos de 5 MB de RAM. Sin cuentas, sin nube.

## ¿Por qué otra app Pomodoro?
La mayoría de los temporizadores Pomodoro son aplicaciones Electron infladas (500 MB de RAM, suscripciones) o herramientas web perdidas en pestañas. Un buen temporizador debe ser invisible hasta que lo necesites e instantáneo cuando lo uses. PomodoroNotch es diferente: nativo SwiftUI, atajo global `⌃⌥⌘P`, cero solicitudes de red, 7 archivos fuente (~1.000 líneas).

## Estados de la barra de menús
| Fase | Pantalla | Color |
|------|----------|-------|
| Inactivo | `·` | Gris transparente |
| Enfoque | `24:59` o `🍅 25m` | Naranja #FF6B35 |
| Descanso corto | `☕ 5m` | Verde #34C759 |
| Descanso largo | `🛋 15m` | Verde #34C759 |
| Pausado | Animación pulsante | Gris #8E8E93 |

## Instalación
Descarga el DMG desde [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest).

## Atajos globales
| Teclas | Acción |
|--------|--------|
| `⌃⌥⌘P` | Iniciar / Pausa / Reanudar |
| `⌃⌥⌘S` | Saltar fase actual |
| `⌃⌥⌘R` | Restablecer |

Requiere permiso de Accesibilidad en Configuración del Sistema.

## Funcionalidades
- **Panel desplegable**: cuenta regresiva de 32pt, controles, estadísticas del día, gráfico semanal
- **12 sonidos tic-tac**: vista previa en preferencias
- **Notificaciones**: sonido+banner / solo sonido / solo banner / desactivado
- **Estadísticas**: almacenadas localmente (JSON)
- **Persistencia de estado**: guardado en cada cambio de fase, restauración exacta tras reinicio
- **11 idiomas**: detección automática o selección manual

## Arquitectura
7 archivos Swift, cero dependencias externas. Enum recursivo `TimerPhase` para la máquina de estados, `NotificationCenter` para desacoplamiento, `@AppStorage` para configuración.

## FAQ
**¿No aparece el icono?** macOS 26+: Configuración del Sistema → Centro de Control → activa PomodoroNotch.
**¿Atajos no funcionan?** Verifica el permiso de Accesibilidad.
MIT © [raymondjxj](https://github.com/raymondjxj)
