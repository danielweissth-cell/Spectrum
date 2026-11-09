import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../playback/media_source.dart';
import '../playback/playback_service.dart';
import 'glass/glass.dart';
import 'spectrum_background.dart';

/// Video surface with Liquid Glass playback controls. For audio-only media it shows a placeholder.
class VideoArea extends StatelessWidget {
  const VideoArea({super.key, required this.playback});

  final PlaybackService playback;

  static const Color _accent = Color(0xFF9DB4FF);

  static const _mobileControls = MaterialVideoControlsThemeData(
    seekOnDoubleTap: true,
    // Light dimming: the glass needs the picture behind it to stay visible.
    backdropColor: Color(0x26000000),
    seekBarPositionColor: _accent,
    seekBarThumbColor: Colors.white,
    primaryButtonBar: [
      Spacer(),
      GlassPanel(
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
      Spacer(),
    ],
    bottomButtonBarMargin: EdgeInsets.fromLTRB(8, 0, 8, 6),
    bottomButtonBar: [
      Expanded(
        child: GlassPanel(
          standalone: true,
          radius: 22,
          child: Padding(
            padding: EdgeInsets.only(left: 14, right: 2),
            child: Row(
              children: [
                MaterialPositionIndicator(),
                Spacer(),
                MaterialFullscreenButton(),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  static const _desktopControls = MaterialDesktopVideoControlsThemeData(
    seekBarPositionColor: _accent,
    seekBarThumbColor: Colors.white,
    bottomButtonBarMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
    bottomButtonBar: [
      Expanded(
        child: GlassPanel(
          standalone: true,
          radius: 24,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                MaterialDesktopSkipPreviousButton(),
                MaterialDesktopPlayOrPauseButton(),
                MaterialDesktopSkipNextButton(),
                MaterialDesktopPositionIndicator(),
                Spacer(),
                MaterialDesktopFullscreenButton(),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: _mobileControls,
      fullscreen: _mobileControls,
      child: MaterialDesktopVideoControlsTheme(
        normal: _desktopControls,
        fullscreen: _desktopControls,
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
              return Stack(
                fit: StackFit.expand,
                children: [
                  const SpectrumBackground(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        title == null ? Icons.link : Icons.music_note,
                        size: 64,
                        color: Colors.white54,
                      ),
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
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
