import 'dart:async';

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../history/history_store.dart';
import '../library/media_library.dart';
import '../library/media_picker.dart';
import '../playback/playback_service.dart';
import 'history_list.dart';
import 'library_list.dart';
import 'link_input.dart';
import 'queue_list.dart';
import 'video_area.dart';

/// Main screen: video on top (or on the left in landscape), link input and lists below.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.playback,
    required this.history,
    required this.library,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final MediaLibrary library;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final StreamSubscription<String> _errorSubscription;
  late final MediaPicker _picker = MediaPicker(widget.library);

  @override
  void initState() {
    super.initState();
    _errorSubscription = widget.playback.player.stream.error.listen(
      _showMessage,
    );
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// A file played earlier may have been deleted since; forget it instead of failing in the player.
  bool _ensureAvailable(String reference) {
    if (widget.library.isAvailable(reference)) return true;
    widget.history.remove(reference);
    _showMessage('This file is no longer on the device.');
    return false;
  }

  void _play(String reference) {
    if (!_ensureAvailable(reference)) return;
    widget.history.record(reference);
    widget.playback.playNow(reference);
  }

  void _enqueue(String reference) {
    if (!_ensureAvailable(reference)) return;
    widget.history.record(reference);
    widget.playback.enqueue(reference);
    _showMessage('Added to queue');
  }

  Future<void> _delete(String reference) async {
    await widget.playback.removeReference(reference);
    await widget.history.remove(reference);
    await widget.library.delete(reference);
  }

  Future<void> _openFiles() async {
    final source = MediaLibrary.importsFiles
        ? await _chooseSource()
        : MediaPickSource.files;
    if (source == null) return;
    final result = await _picker.pick(source);
    if (result.rejectedNames.isNotEmpty) {
      _showMessage(
        'Not an audio or video file: ${result.rejectedNames.join(', ')}',
      );
    }
    final references = result.references;
    if (references.isEmpty) return;
    // The first picked file starts now, the rest wait in the queue.
    _play(references.first);
    for (final reference in references.skip(1)) {
      widget.history.record(reference);
      await widget.playback.enqueue(reference);
    }
  }

  Future<MediaPickSource?> _chooseSource() {
    return showModalBottomSheet<MediaPickSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Files'),
              subtitle: const Text('Music and video from the Files app'),
              onTap: () => Navigator.pop(context, MediaPickSource.files),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Photo library'),
              subtitle: const Text('Videos from your gallery'),
              onTap: () => Navigator.pop(context, MediaPickSource.photos),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = VideoArea(playback: widget.playback);
    final panel = _ControlPanel(
      playback: widget.playback,
      history: widget.history,
      library: widget.library,
      onPlay: _play,
      onEnqueue: _enqueue,
      onDelete: _delete,
      onOpenFiles: _openFiles,
    );
    return Scaffold(
      appBar: AppBar(title: const Text(appName)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            if (isLandscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: video),
                  Expanded(flex: 2, child: panel),
                ],
              );
            }
            return Column(
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: video),
                Expanded(child: panel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.playback,
    required this.history,
    required this.library,
    required this.onPlay,
    required this.onEnqueue,
    required this.onDelete,
    required this.onOpenFiles,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final MediaLibrary library;
  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenFiles;

  @override
  Widget build(BuildContext context) {
    final showLibrary = MediaLibrary.importsFiles;
    return DefaultTabController(
      length: showLibrary ? 3 : 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: LinkInput(
              onPlay: onPlay,
              onEnqueue: onEnqueue,
              onOpenFiles: onOpenFiles,
            ),
          ),
          TabBar(
            tabs: [
              const Tab(text: 'Queue'),
              if (showLibrary) const Tab(text: 'Library'),
              const Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                QueueList(playback: playback),
                if (showLibrary)
                  LibraryList(
                    library: library,
                    onPlay: onPlay,
                    onEnqueue: onEnqueue,
                    onDelete: onDelete,
                  ),
                HistoryList(
                  history: history,
                  onPlay: onPlay,
                  onEnqueue: onEnqueue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
