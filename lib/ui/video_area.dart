import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../playback/media_source.dart';
import '../playback/playback_service.dart';
import 'glass/glass.dart';
import 'style/style_background.dart';
import 'style/style_look.dart';

/// Video surface with Liquid Glass playback controls. For audio-only media it shows a placeholder.
class VideoArea extends StatelessWidget {
  const VideoArea({super.key, required this.playback});

  final PlaybackService playback;

  static const Color _seekColor = Color(0xFF9DB4FF);

  /// Buttons sit on glass panels, so they take the panel text colour of the style.
  static MaterialVideoControlsThemeData _mobileControls(StyleLook look) =>
      MaterialVideoControlsThemeData(
        seekOnDoubleTap: true,
        // Light dimming: the glass needs the picture behind it to stay visible.
        backdropColor: const Color(0x26000000),
        seekBarPositionColor: _seekColor,
        seekBarThumbColor: Colors.white,
        buttonBarButtonColor: look.foreground,
        primaryButtonBar: [
          const Spacer(),
          const GlassPanel(
            standalone: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialSkipPreviousButton(),
                  MaterialPlayOrPauseButton(iconSize: 40),
                  MaterialSkipNextButton(),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
        bottomButtonBarMargin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        bottomButtonBar: [
          Expanded(
            child: GlassPanel(
              standalone: true,
              radius: 22,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, right: 2),
                child: Row(
                  children: [
                    MaterialPositionIndicator(
                      style: TextStyle(color: look.foreground, fontSize: 14),
                    ),
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  static MaterialDesktopVideoControlsThemeData _desktopControls(
    StyleLook look,
  ) => MaterialDesktopVideoControlsThemeData(
    seekBarPositionColor: _seekColor,
    seekBarThumbColor: Colors.white,
    buttonBarButtonColor: look.foreground,
    bottomButtonBarMargin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    bottomButtonBar: [
      Expanded(
        child: GlassPanel(
          standalone: true,
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                const MaterialDesktopSkipPreviousButton(),
                const MaterialDesktopPlayOrPauseButton(),
                const MaterialDesktopSkipNextButton(),
                MaterialDesktopPositionIndicator(
                  style: TextStyle(color: look.foreground, fontSize: 14),
                ),
                const Spacer(),
                const MaterialDesktopFullscreenButton(),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final look = StyleLook.of(context);
    final mobileControls = _mobileControls(look);
    final desktopControls = _desktopControls(look);
    return MaterialVideoControlsTheme(
      normal: mobileControls,
      fullscreen: mobileControls,
      child: MaterialDesktopVideoControlsTheme(
        normal: desktopControls,
        fullscreen: desktopControls,
        child: Video(
          controller: playback.videoController,
          // Sound keeps playing in the background; PlaybackService turns the picture off there.
          pauseUponEnteringBackgroundMode: false,
          // The placeholder sits between the picture and the controls, so it hides the last
          // frame of a previous video when an audio item follows it in the queue.
          // BackdropGroup lets all glass in the controls share one copy of the picture.
          controls: (state) => BackdropGroup(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _AudioPlaceholder(playback: playback),
                AdaptiveVideoControls(state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Colourful cover with a note icon and the title, shown while the current item has no picture.
class _AudioPlaceholder extends StatelessWidget {
  const _AudioPlaceholder({required this.playback});

  final PlaybackService playback;

  /// Album art counts as a picture: libmpv shows it as a still video track.
  static bool _hasPicture(Tracks tracks) =>
      tracks.video.any((track) => track.id != 'auto' && track.id != 'no');

  @override
  Widget build(BuildContext context) {
    final player = playback.player;
    return StreamBuilder<Tracks>(
      // Track list is refreshed for every file, unlike the video size, which keeps the
      // previous value when the queue moves from a video to an audio item.
      stream: player.stream.tracks,
      initialData: player.state.tracks,
      builder: (context, tracksSnapshot) {
        if (_hasPicture(tracksSnapshot.data ?? const Tracks())) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<Playlist>(
          stream: player.stream.playlist,
          initialData: player.state.playlist,
          builder: (context, _) => ValueListenableBuilder<String?>(
            valueListenable: playback.streamTitle,
            builder: (context, streamTitle, _) {
              final reference = playback.currentReference;
              final title = reference == null
                  ? null
                  : streamTitle ?? MediaSource.displayName(reference);
              final look = StyleLook.of(context);
              return Stack(
                fit: StackFit.expand,
                children: [
                  const StyleBackground(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        title == null ? Icons.link : Icons.music_note,
                        size: 64,
                        color: look.foregroundMuted,
                      ),
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: look.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
