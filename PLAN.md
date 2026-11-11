# PLAN: Spectrum

- [x] 0. Setup: Flutter, CocoaPods, project in `~/Developer/MediaPlayer`, git.
- [x] 1. First sound and picture: URL field + Play, checked on Mac and iPhone.
- [x] 2. Real player: pause, seek, volume, fullscreen video, link history, playlist.
- [x] 3. Background playback: lock screen, Dynamic Island, headphone buttons, calls.
- [x] 3a. Local files: Files app and photo library, Library tab ("On My iPhone > Spectrum").
- [ ] 4. Android and Linux builds and fixes. Android adaptive icon (layered, so the launcher does not shrink it), Linux desktop icon.
  - [x] Android: builds, installs on Redmi (Android 12), adaptive icon.
  - [ ] Android: lock screen pause/next do not work on Redmi (MIUI). Commands are now logged as `[media command]`
        (logcat tag `flutter`); next test: `adb logcat -s flutter` while pressing the buttons.
  - [x] Linux: Raspberry Pi 4 (Raspberry Pi OS 13, arm64): builds on the Pi, MPRIS, menu entry.
  - [ ] Linux: video uses software rendering on the Pi ("EGL display or context is invalid"); fine for 720p, check heavier video later.
- [ ] 5. Polish: English + Russian UI, app icon, network error handling.
  - [x] Localization: ARB files in `lib/l10n` (English source, Russian), system language, iOS `CFBundleLocalizations`.
  - [x] Playback errors shown as translated messages instead of raw libmpv text.
  - [x] App icon (done with the rename to Spectrum).
  - [ ] Check on devices: iPhone (installed), Redmi and Pi (not updated yet).
  - [ ] iOS photo permission text is English only (needs `ru.lproj/InfoPlist.strings` in the Xcode project);
        not shown in practice, the photo picker needs no permission.
- [x] 6. Liquid Glass design: coloured background, floating glass tab bar, glass link bar, glass video controls.
  - [x] Built; checked in the iOS simulator; installed on iPhone.
  - [x] Checked on iPhone; Pi builds (no Flutter GPU on Linux: blur fallback, shaders not precached).
  - [ ] Redmi: performance not checked yet.
- [ ] 7. Settings screen (gear button), saved between launches.
  - [x] Step 1: language (system / English / Russian), Liquid Glass on/off, volume gain 0.5–5.0×, speed 0.5–5.0×.
        Checked on iPhone and Pi. Glass off = solid plates. Lock screen / Dynamic Island are drawn by iOS
        and do not follow the switch.
  - [x] Step 2: styles (default Dark) Rainbow, 64 Bit (pixel sunset, Press Start 2P font with Cyrillic, square corners,
        thick frames), Dark, White. Built, checked in the simulator, installed on iPhone. Waiting for the user's check.
  - [x] Pi and Redmi updated with settings and styles.
- [ ] Later: Picture-in-Picture for video on iOS.
