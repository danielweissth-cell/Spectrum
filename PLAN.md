# PLAN: Spectrum

- [x] 0. Setup: Flutter, CocoaPods, project in `~/Developer/MediaPlayer`, git.
- [x] 1. First sound and picture: URL field + Play, checked on Mac and iPhone.
- [x] 2. Real player: pause, seek, volume, fullscreen video, link history, playlist.
- [x] 3. Background playback: lock screen, Dynamic Island, headphone buttons, calls.
- [x] 3a. Local files: Files app and photo library, Library tab ("On My iPhone > Spectrum").
- [ ] 4. Android and Linux builds and fixes. Android adaptive icon (layered, so the launcher does not shrink it), Linux desktop icon.
  - [x] Android: builds, installs on Redmi (Android 12), adaptive icon.
  - [ ] Android: lock screen pause/next do not work on Redmi (MIUI). Not diagnosed yet: need a log while the buttons are pressed.
  - [x] Linux: Raspberry Pi 4 (Raspberry Pi OS 13, arm64): builds on the Pi, MPRIS, menu entry.
  - [ ] Linux: video uses software rendering on the Pi ("EGL display or context is invalid"); fine for 720p, check heavier video later.
- [ ] 5. Polish: English + Russian UI, app icon, network error handling.
- [ ] Later: Picture-in-Picture for video on iOS.
