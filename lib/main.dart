import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app_info.dart';
import 'history/history_store.dart';
import 'playback/playback_service.dart';
import 'ui/player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final history = HistoryStore();
  await history.load();
  runApp(MediaPlayerApp(playback: PlaybackService(), history: history));
}

class MediaPlayerApp extends StatelessWidget {
  const MediaPlayerApp({
    super.key,
    required this.playback,
    required this.history,
  });

  final PlaybackService playback;
  final HistoryStore history;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: PlayerScreen(playback: playback, history: history),
    );
  }
}
