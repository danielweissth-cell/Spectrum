# CLAUDE.md: Spectrum media player (Flutter)

## 0. Before any work
Read [PLAN.md](PLAN.md): current stage and checkboxes.

## 1. User and communication
- Talk to the user **in Russian**. Code, names, comments in **English**.
- The user is new to Flutter: explain editor/terminal steps in detail.
- "Right from the start": no temporary hacks. If a simplification is needed, say so and write it in PLAN.md.

## 2. Workflow
- Plan first, then code. Small steps: one step -> user checks -> commit -> next.
- Commit only when the user agrees. Commit messages in English, imperative mood.
- GitHub: public repo https://github.com/danielweissth-cell/Spectrum (`origin`, branch `main`). Push after each
  agreed commit. The repo is public: never commit keys, passwords or signing files.
- Do not do more than asked.

## 3. Architecture
- Platforms: **iOS, Android, Linux**. macOS build is only for quick testing on the Mac.
- Stack: Flutter (Dart), `media_kit` for playback (libmpv), `audio_service` for background playback,
  lock screen and Dynamic Island (via iOS Now Playing).
- Playback sources: network links (http/https files, HLS streams) and local files.
  Stored as references (`lib/playback/media_source.dart`): URL, `library:<file name>`, or an absolute path (desktop).
- Local files on phones are moved into the app library (`MediaLibrary`): iOS Documents, visible in Files as
  "On My iPhone > Spectrum". Pickers only give temporary copies, so files are not played from the temp folder.
  Library files are stored by name, not by full path: the iOS container path changes between installs.
- Background: `SystemMediaHandler` (audio_service + audio_session). Video track is switched off in the background
  (`vid=no`), sound continues. Picture-in-Picture is not done yet.
- Design: Liquid Glass via `liquid_glass_renderer` pinned to `1.0.0-dev.2` (experimental, needs Impeller + Flutter GPU:
  `FLTEnableFlutterGPU` in iOS/macOS Info.plist, `EnableFlutterGPU` meta-data on Android; elsewhere it falls back to blur).
  Only `lib/ui/glass/glass.dart` imports it. Glass refracts what is painted before it: floating glass goes into the one
  `GlassLayer` painted after the content (main screen); glass in the video controls uses `standalone` + `BackdropGroup`.
  Glass only for controls and navigation, never for list content. Coloured `SpectrumBackground` behind everything.
- Settings live in `lib/settings/app_settings.dart` (`AppSettings`, SharedPreferencesAsync). Volume is a gain
  (1.0 = file loudness, up to 5.0, mpv `volume-max` 500) and is set only in Settings: the desktop volume button
  was removed so two controls do not fight. Glass on/off goes through `GlassScope`; off = solid plates.
- Debug: libmpv log goes to the console (`[mpv]`), Now Playing updates are logged as `[now playing]`.
  Release builds on iOS do not show these; use `flutter run` with a cable to see them.
- Localization: English (source) + Russian, language follows the system. Every user-visible text goes into
  `lib/l10n/app_en.arb` and `app_ru.arb` with a meaningful key, used as `AppLocalizations.of(context).key`.
  No string concatenation: placeholders and ICU plurals (`one/few/many/other` for Russian). After editing ARB files
  run `flutter gen-l10n` (also runs automatically on build). The name Spectrum is not translated (`lib/app_info.dart`).

## 4. Environment (checked 2026-11-06)
- Flutter 3.47.9 via Homebrew (`/opt/homebrew/bin/flutter`), CocoaPods 1.17.0, Xcode 27.0.
- App name: **Spectrum** (`lib/app_info.dart`). Bundle id stays `com.danielweissth.mediaPlayer`, Dart package `media_player`.
- App icon source: `assets/icon/app_icon.png`, regenerate with `dart run flutter_launcher_icons`.
- iOS signing: free Personal Team (same as Tower Defense).
- Linux: Raspberry Pi 4, user `dan@192.168.50.120` (SSH key login, passwordless sudo). Flutter 3.47.9 in `~/development/flutter`,
  project copy in `~/development/MediaPlayer` (sync with rsync, then `flutter build linux --release` on the Pi).
  Run on the Pi screen over SSH: `XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0`. Menu entry: `linux/packaging/install_desktop_entry.sh`.
- Android: Redmi (Android 12, MIUI). adb: `~/Library/Android/sdk/platform-tools/adb`. MIUI blocks `adb install` unless
  "Install via USB" is on; fallback is `adb push` to Download and installing by hand.
- Run on Mac: `flutter run -d macos`. On iPhone: `flutter run -d <device>` (list: `flutter devices`).
