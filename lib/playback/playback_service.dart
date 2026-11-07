import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'media_source.dart';

/// Owns the single [Player] of the app and exposes queue operations.
///
/// Callers pass stored references (see [MediaSource]); [resolve] turns them into
/// paths or URLs libmpv can open. The reference is kept in [Media.extras] so the
/// queue can always be mapped back to it.
class PlaybackService {
  PlaybackService({required this.resolve})
    : player = Player(
        configuration: const PlayerConfiguration(
          logLevel: kDebugMode ? MPVLogLevel.warn : MPVLogLevel.error,
        ),
      ) {
    // Forward libmpv messages to the console so playback problems can be diagnosed.
    player.stream.log.listen((log) {
      debugPrint('[mpv] ${log.level} ${log.prefix}: ${log.text.trim()}');
    });
    _observeMetadata();
    _lifecycleListener = AppLifecycleListener(
      onHide: () => _setVideoDecoding(enabled: false),
      onShow: () => _setVideoDecoding(enabled: true),
    );
  }

  static const String _referenceKey = 'reference';

  final Player player;
  final String Function(String reference) resolve;
  late final VideoController videoController = VideoController(player);
  late final AppLifecycleListener _lifecycleListener;

  /// Title reported by the stream itself (file tags or internet radio "now playing"), if any.
  final ValueNotifier<String?> streamTitle = ValueNotifier(null);

  /// Artist from the file tags, if any.
  final ValueNotifier<String?> streamArtist = ValueNotifier(null);

  /// Stored reference of a queue item.
  static String referenceOf(Media media) =>
      media.extras?[_referenceKey] as String? ?? media.uri;

  /// Stored reference of the item that is playing now, or null if the queue is empty.
  String? get currentReference {
    final playlist = player.state.playlist;
    if (playlist.index < 0 || playlist.index >= playlist.medias.length) {
      return null;
    }
    return referenceOf(playlist.medias[playlist.index]);
  }

  bool get _isQueueEmpty => player.state.playlist.medias.isEmpty;

  Media _mediaFor(String reference) =>
      Media(resolve(reference), extras: {_referenceKey: reference});

  /// Starts [reference] right away. It is inserted after the current item, so the rest of the queue is kept.
  Future<void> playNow(String reference) async {
    if (_isQueueEmpty) {
      await player.open(_mediaFor(reference));
      return;
    }
    await player.add(_mediaFor(reference));
    final lastIndex = player.state.playlist.medias.length - 1;
    final targetIndex = player.state.playlist.index + 1;
    if (lastIndex != targetIndex) {
      await player.move(lastIndex, targetIndex);
    }
    await player.jump(targetIndex);
  }

  /// Appends [reference] to the end of the queue without interrupting playback.
  Future<void> enqueue(String reference) async {
    if (_isQueueEmpty) {
      await player.open(Playlist([_mediaFor(reference)]), play: false);
      return;
    }
    await player.add(_mediaFor(reference));
  }

  Future<void> jumpTo(int index) => player.jump(index);

  Future<void> removeAt(int index) => player.remove(index);

  /// Removes every queue item with this reference, for example after its file was deleted.
  Future<void> removeReference(String reference) async {
    final medias = player.state.playlist.medias;
    for (var index = medias.length - 1; index >= 0; index--) {
      if (referenceOf(medias[index]) == reference) await player.remove(index);
    }
  }

  /// Moves the item at [oldIndex] so that it ends up at [finalIndex].
  Future<void> move(int oldIndex, int finalIndex) {
    // libmpv expects the insertion point counted before the item is removed.
    final insertBefore = finalIndex > oldIndex ? finalIndex + 1 : finalIndex;
    return player.move(oldIndex, insertBefore);
  }

  Future<void> dispose() async {
    _lifecycleListener.dispose();
    streamTitle.dispose();
    streamArtist.dispose();
    await player.dispose();
  }

  void _observeMetadata() {
    final platform = player.platform;
    if (platform is! NativePlayer) return;
    // "media-title" is the tag title, the radio "now playing" text, or the file name as a fallback.
    platform.observeProperty('media-title', (value) async {
      streamTitle.value = value.isEmpty ? null : value;
    });
    platform.observeProperty('metadata/by-key/artist', (value) async {
      streamArtist.value = value.isEmpty ? null : value;
    });
  }

  /// iOS forbids GPU rendering in the background, and decoding frames nobody sees wastes
  /// battery. Turning the video track off keeps the sound playing; it comes back on return.
  Future<void> _setVideoDecoding({required bool enabled}) async {
    final platform = player.platform;
    if (platform is! NativePlayer || _isQueueEmpty) return;
    debugPrint('[playback] video decoding ${enabled ? 'on' : 'off'}');
    await platform.setProperty('vid', enabled ? 'auto' : 'no');
  }
}
