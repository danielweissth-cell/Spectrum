import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

import 'media_source.dart';
import 'playback_service.dart';

/// Connects [PlaybackService] to the operating system media controls:
/// iOS lock screen and Dynamic Island (Now Playing), Android media notification,
/// Linux MPRIS, headphone buttons. It also reacts to audio interruptions (calls).
class SystemMediaHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  SystemMediaHandler({
    required this.playback,
    required this.session,
    required this.fallbackArtwork,
  }) {
    final stream = playback.player.stream;
    _subscriptions.addAll([
      stream.playing.listen((_) => _publishState()),
      stream.buffering.listen((_) => _publishState()),
      stream.completed.listen((_) => _publishState()),
      // The lock screen moves the progress bar by itself and needs the current speed for that.
      stream.rate.listen((_) => _publishState()),
      stream.duration.listen((_) => _publishItem()),
      stream.playlist.listen((_) {
        _publishQueue();
        _publishItem();
        _publishState();
      }),
      stream.position.listen(_onPosition),
      session.interruptionEventStream.listen(_onInterruption),
      session.becomingNoisyEventStream.listen((_) => pause()),
    ]);
    playback.streamTitle.addListener(_publishItem);
    playback.streamArtist.addListener(_publishItem);
  }

  final PlaybackService playback;
  final AudioSession session;

  /// Shown on the lock screen when the media has no cover of its own.
  final Uri? fallbackArtwork;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _resumeAfterInterruption = false;

  /// Creates the handler and registers it with the system.
  static Future<SystemMediaHandler> start({
    required PlaybackService playback,
    required String notificationChannelName,
    Uri? fallbackArtwork,
  }) async {
    final session = await AudioSession.instance;
    // Music category: plays with the silent switch on and in the background.
    await session.configure(const AudioSessionConfiguration.music());
    return AudioService.init(
      builder: () => SystemMediaHandler(
        playback: playback,
        session: session,
        fallbackArtwork: fallbackArtwork,
      ),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.danielweissth.mediaPlayer.playback',
        androidNotificationChannelName: notificationChannelName,
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  Player get _player => playback.player;

  // Commands from the system (lock screen, Dynamic Island, headphones, notification).

  @override
  Future<void> play() async {
    _logCommand('play');
    if (await session.setActive(true)) await _player.play();
  }

  @override
  Future<void> pause() {
    _logCommand('pause');
    return _player.pause();
  }

  @override
  Future<void> stop() async {
    _logCommand('stop');
    await _player.stop();
    await session.setActive(false);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    _logCommand('seek $position');
    await _player.seek(position);
    _publishState();
  }

  @override
  Future<void> skipToNext() {
    _logCommand('next');
    return _player.next();
  }

  @override
  Future<void> skipToPrevious() async {
    _logCommand('previous');
    // Like most players: restart the track first, go to the previous one only near its start.
    if (_player.state.position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
    } else {
      await _player.previous();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) {
    _logCommand('jump $index');
    return _player.jump(index);
  }

  /// Logged in release builds too (Android logcat tag "flutter"), to check that
  /// lock screen, notification and headphone buttons reach the app.
  static void _logCommand(String command) =>
      debugPrint('[media command] $command');

  // State published to the system.

  void _onPosition(Duration position) {
    // The system extrapolates the position itself; republish only when it jumped (seek, stall).
    final expected = playbackState.value.position;
    if ((position - expected).abs() > const Duration(seconds: 2)) {
      _publishState();
    }
  }

  void _onInterruption(AudioInterruptionEvent event) {
    if (event.begin) {
      if (event.type == AudioInterruptionType.duck) return;
      _resumeAfterInterruption = _player.state.playing;
      _player.pause();
    } else if (_resumeAfterInterruption &&
        event.type == AudioInterruptionType.pause) {
      // Resume only if the system says so (for example after a phone call).
      _resumeAfterInterruption = false;
      play();
    } else {
      _resumeAfterInterruption = false;
    }
  }

  void _publishState() {
    final state = _player.state;
    final processingState = state.playlist.medias.isEmpty
        ? AudioProcessingState.idle
        : state.completed
        ? AudioProcessingState.completed
        : state.buffering
        ? AudioProcessingState.buffering
        : AudioProcessingState.ready;
    final hasQueue = state.playlist.medias.length > 1;
    playbackState.add(
      PlaybackState(
        controls: [
          if (hasQueue) MediaControl.skipToPrevious,
          state.playing ? MediaControl.pause : MediaControl.play,
          if (hasQueue) MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: hasQueue ? const [0, 1, 2] : const [0],
        processingState: processingState,
        playing: state.playing,
        updatePosition: state.position,
        bufferedPosition: state.buffer,
        speed: state.rate,
        queueIndex: state.playlist.medias.isEmpty ? null : state.playlist.index,
      ),
    );
  }

  void _publishQueue() {
    queue.add([
      for (final media in _player.state.playlist.medias)
        _baseItem(PlaybackService.referenceOf(media)),
    ]);
  }

  void _publishItem() {
    final reference = playback.currentReference;
    if (reference == null) {
      mediaItem.add(null);
      return;
    }
    final base = _baseItem(reference);
    final streamTitle = playback.streamTitle.value;
    final duration = _player.state.duration;
    mediaItem.add(
      base.copyWith(
        title: streamTitle ?? base.title,
        artist: playback.streamArtist.value ?? base.artist,
        // Live streams report zero; null tells the system there is no progress bar.
        duration: duration > Duration.zero ? duration : null,
      ),
    );
    debugPrint('[now playing] ${streamTitle ?? base.title}');
  }

  MediaItem _baseItem(String reference) => MediaItem(
    id: reference,
    title: MediaSource.displayName(reference),
    artist: MediaSource.host(reference),
    artUri: fallbackArtwork,
  );

  Future<void> dispose() async {
    playback.streamTitle.removeListener(_publishItem);
    playback.streamArtist.removeListener(_publishItem);
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
