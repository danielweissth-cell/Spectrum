import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../playback/media_source.dart';
import '../playback/playback_service.dart';

/// Video surface with playback controls. For audio-only media it shows a placeholder.
class VideoArea extends StatelessWidget {
  const VideoArea({super.key, required this.playback});

  final PlaybackService playback;

  static const _mobileControls = MaterialVideoControlsThemeData(
    seekOnDoubleTap: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: _mobileControls,
      fullscreen: _mobileControls,
      child: Video(
        controller: playback.videoController,
        // Sound keeps playing in the background; PlaybackService turns the picture off there.
        pauseUponEnteringBackgroundMode: false,
        // The placeholder sits between the picture and the controls, so it hides the last
        // frame of a previous video when an audio item follows it in the queue.
        controls: (state) => Stack(
          fit: StackFit.expand,
          children: [
            _AudioPlaceholder(playback: playback),
            AdaptiveVideoControls(state),
          ],
        ),
      ),
    );
  }
}

/// Opaque cover with a note icon and the title, shown while the current item has no picture.
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
              return ColoredBox(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      title == null ? Icons.link : Icons.music_note,
                      size: 64,
                      color: Colors.white38,
                    ),
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
