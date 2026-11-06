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
- Do not do more than asked.

## 3. Architecture
- Platforms: **iOS, Android, Linux**. macOS build is only for quick testing on the Mac.
- Stack: Flutter (Dart), `media_kit` for playback (libmpv), `audio_service` for background playback,
  lock screen and Dynamic Island (via iOS Now Playing).
- Playback source: network links (http/https files, HLS streams).
- Player-visible text will be localized (English + Russian) at stage 5; until then text is in English.

## 4. Environment (checked 2026-11-06)
- Flutter 3.47.9 via Homebrew (`/opt/homebrew/bin/flutter`), CocoaPods 1.17.0, Xcode 27.0.
- App name: **Spectrum** (`lib/app_info.dart`). Bundle id stays `com.danielweissth.mediaPlayer`, Dart package `media_player`.
- App icon source: `assets/icon/app_icon.png`, regenerate with `dart run flutter_launcher_icons`.
- iOS signing: free Personal Team (same as Tower Defense).
- Android: cmdline-tools and licenses not set up yet (needed at stage 4).
- Linux builds need a Linux machine (planned: UTM virtual machine, stage 4).
- Run on Mac: `flutter run -d macos`. On iPhone: `flutter run -d <device>` (list: `flutter devices`).
