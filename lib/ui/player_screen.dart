import 'dart:async';

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../history/history_store.dart';
import '../playback/playback_service.dart';
import 'history_list.dart';
import 'link_input.dart';
import 'queue_list.dart';
import 'video_area.dart';

/// Main screen: video on top (or on the left in landscape), link input and queue/history below.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.playback,
    required this.history,
  });

  final PlaybackService playback;
  final HistoryStore history;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final StreamSubscription<String> _errorSubscription;

  @override
  void initState() {
    super.initState();
    _errorSubscription = widget.playback.player.stream.error.listen(_showError);
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _play(String url) {
    widget.history.record(url);
    widget.playback.playNow(url);
  }

  void _enqueue(String url) {
    widget.history.record(url);
    widget.playback.enqueue(url);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Added to queue')));
  }

  @override
  Widget build(BuildContext context) {
    final video = VideoArea(playback: widget.playback);
    final panel = _ControlPanel(
      playback: widget.playback,
      history: widget.history,
      onPlay: _play,
      onEnqueue: _enqueue,
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
    required this.onPlay,
    required this.onEnqueue,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: LinkInput(onPlay: onPlay, onEnqueue: onEnqueue),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Queue'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                QueueList(playback: playback),
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
