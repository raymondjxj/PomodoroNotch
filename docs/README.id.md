# 🍅 PomodoroNotch
**Timer Pomodoro yang tidak mengganggu.** Di bilah menu. Dikendalikan keyboard. RAM <5 MB. Tanpa akun, tanpa cloud.

## Kenapa aplikasi Pomodoro lagi?
Kebanyakan timer Pomodoro adalah aplikasi Electron yang berat (500 MB RAM, berlangganan) atau alat web yang tenggelam di tab browser. Timer yang baik harus tak terlihat sampai dibutuhkan, lalu instan saat digunakan. PomodoroNotch berbeda: native SwiftUI, pintasan global `⌃⌥⌘P`, nol permintaan jaringan, 7 file sumber (~1.000 baris).

## Status Bilah Menu
| Fase | Tampilan | Warna |
|------|----------|-------|
| Diam | `·` | Abu-abu transparan |
| Fokus | `24:59` atau `🍅 25m` | Oranye #FF6B35 |
| Istirahat Singkat | `☕ 5m` | Hijau #34C759 |
| Istirahat Panjang | `🛋 15m` | Hijau #34C759 |
| Dijeda | Animasi berdenyut | Abu-abu #8E8E93 |

## Instalasi
Unduh DMG dari [Releases](https://github.com/raymondjxj/PomodoroNotch/releases/latest).

## Pintasan Global
| Tombol | Aksi |
|--------|------|
| `⌃⌥⌘P` | Mulai / Jeda / Lanjutkan |
| `⌃⌥⌘S` | Lewati fase saat ini |
| `⌃⌥⌘R` | Atur ulang |

Memerlukan izin Aksesibilitas di Pengaturan Sistem.

## Fitur
- **Panel dropdown**: hitung mundur 32pt, kontrol, statistik harian, grafik mingguan
- **12 suara tik**: pratinjau langsung di preferensi
- **Notifikasi**: suara+spanduk / hanya suara / hanya spanduk / mati
- **Statistik**: disimpan lokal (JSON)
- **Persistensi status**: disimpan setiap perubahan fase, pulih tepat setelah mulai ulang
- **11 bahasa**: deteksi otomatis atau pilihan manual

## Arsitektur
7 file Swift, nol dependensi eksternal. Enum rekursif `TimerPhase` untuk mesin status, `NotificationCenter` untuk pemisahan modul, `@AppStorage` untuk pengaturan.

## FAQ
**Ikon tidak muncul?** macOS 26+: Pengaturan Sistem → Pusat Kontrol → aktifkan PomodoroNotch.
**Pintasan tidak berfungsi?** Periksa izin Aksesibilitas.
MIT © [raymondjxj](https://github.com/raymondjxj)
