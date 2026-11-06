import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Owns the single [Player] of the app and exposes queue operations.
///
/// UI widgets read state from [player] streams and call these methods;
/// they never manipulate the player directly.
class PlaybackService {
  PlaybackService()
    : player = Player(
        configuration: const PlayerConfiguration(
          logLevel: kDebugMode ? MPVLogLevel.warn : MPVLogLevel.error,
        ),
      ) {
    // Forward libmpv messages to the console so playback problems can be diagnosed.
    player.stream.log.listen((log) {
      debugPrint('[mpv] ${log.level} ${log.prefix}: ${log.text.trim()}');
    });
  }

  final Player player;
  late final VideoController videoController = VideoController(player);

  bool get _isQueueEmpty => player.state.playlist.medias.isEmpty;

  /// Starts [url] right away. It is inserted after the current item, so the rest of the queue is kept.
  Future<void> playNow(String url) async {
    if (_isQueueEmpty) {
      await player.open(Media(url));
      return;
    }
    await player.add(Media(url));
    final lastIndex = player.state.playlist.medias.length - 1;
    final targetIndex = player.state.playlist.index + 1;
    if (lastIndex != targetIndex) {
      await player.move(lastIndex, targetIndex);
    }
    await player.jump(targetIndex);
  }

  /// Appends [url] to the end of the queue without interrupting playback.
  Future<void> enqueue(String url) async {
    if (_isQueueEmpty) {
      await player.open(Playlist([Media(url)]), play: false);
      return;
    }
    await player.add(Media(url));
  }

  Future<void> jumpTo(int index) => player.jump(index);

  Future<void> removeAt(int index) => player.remove(index);

  /// Moves the item at [oldIndex] so that it ends up at [finalIndex].
  Future<void> move(int oldIndex, int finalIndex) {
    // libmpv expects the insertion point counted before the item is removed.
    final insertBefore = finalIndex > oldIndex ? finalIndex + 1 : finalIndex;
    return player.move(oldIndex, insertBefore);
  }

  Future<void> dispose() => player.dispose();
}
