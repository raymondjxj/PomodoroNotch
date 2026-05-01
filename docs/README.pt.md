# 🍅 PomodoroNotch
**O temporizador Pomodoro que não atrapalha.** Na barra de menus. Controlado por teclado. Menos de 5 MB de RAM. Sem contas, sem nuvem.

## Por que outro app Pomodoro?
A maioria dos temporizadores Pomodoro são apps Electron pesados (500 MB de RAM, assinaturas) ou ferramentas web perdidas em abas. Um bom temporizador deve ser invisível até você precisar e instantâneo quando usar. PomodoroNotch é diferente: nativo SwiftUI, atalho global `⌃⌥⌘P`, zero requisições de rede, 7 arquivos fonte (~1.000 linhas).

## Estados da barra de menus
| Fase | Exibição | Cor |
|------|----------|-----|
| Inativo | `·` | Cinza transparente |
| Foco | `24:59` ou `🍅 25m` | Laranja #FF6B35 |
| Pausa curta | `☕ 5m` | Verde #34C759 |
| Pausa longa | `🛋 15m` | Verde #34C759 |
| Pausado | Animação pulsante | Cinza #8E8E93 |

## Instalação
Baixe o DMG em [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest).

## Atalhos globais
| Teclas | Ação |
|--------|------|
| `⌃⌥⌘P` | Iniciar / Pausa / Continuar |
| `⌃⌥⌘S` | Pular fase atual |
| `⌃⌥⌘R` | Redefinir |

Requer permissão de Acessibilidade nos Ajustes do Sistema.

## Funcionalidades
- **Painel suspenso**: contagem regressiva 32pt, controles, estatísticas do dia, gráfico semanal
- **12 sons tique-taque**: pré-visualização nas preferências
- **Notificações**: som+banner / só som / só banner / desligado
- **Estatísticas**: armazenadas localmente (JSON)
- **Persistência de estado**: salvo a cada mudança de fase, restauração exata após reinício
- **11 idiomas**: detecção automática ou seleção manual

## Arquitetura
7 arquivos Swift, zero dependências externas. Enum recursivo `TimerPhase` para máquina de estados, `NotificationCenter` para desacoplamento, `@AppStorage` para configurações.

## FAQ
**Ícone não aparece?** macOS 26+: Ajustes do Sistema → Central de Controle → ative o PomodoroNotch.
**Atalhos não funcionam?** Verifique a permissão de Acessibilidade.
MIT © [raymondjxj](https://github.com/raymondjxj)
