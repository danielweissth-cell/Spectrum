import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../playback/media_link.dart';
import '../playback/playback_service.dart';

/// Video surface with playback controls. For audio-only links it shows a placeholder behind the controls.
class VideoArea extends StatelessWidget {
  const VideoArea({super.key, required this.playback});

  final PlaybackService playback;

  static const _mobileControls = MaterialVideoControlsThemeData(
    seekOnDoubleTap: true,
  );

  @override
  Widget build(BuildContext context) {
    final player = playback.player;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          StreamBuilder<int?>(
            stream: player.stream.width,
            initialData: player.state.width,
            builder: (context, widthSnapshot) {
              final hasVideo = (widthSnapshot.data ?? 0) > 0;
              if (hasVideo) return const SizedBox.shrink();
              return StreamBuilder<Playlist>(
                stream: player.stream.playlist,
                initialData: player.state.playlist,
                builder: (context, playlistSnapshot) =>
                    _AudioPlaceholder(playlist: playlistSnapshot.data),
              );
            },
          ),
          MaterialVideoControlsTheme(
            normal: _mobileControls,
            fullscreen: _mobileControls,
            child: Video(
              controller: playback.videoController,
              // Transparent so the audio placeholder stays visible when there is no video track.
              fill: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioPlaceholder extends StatelessWidget {
  const _AudioPlaceholder({required this.playlist});

  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    final medias = playlist?.medias ?? const <Media>[];
    final index = playlist?.index ?? 0;
    final title = index < medias.length
        ? MediaLink.displayName(medias[index].uri)
        : null;
    return Column(
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
    );
  }
}
