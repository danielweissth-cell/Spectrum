import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_info.dart';
import 'history/history_store.dart';
import 'library/media_library.dart';
import 'playback/playback_service.dart';
import 'playback/system_media_handler.dart';
import 'ui/player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final library = MediaLibrary();
  final history = HistoryStore();
  await Future.wait([library.load(), history.load()]);

  final playback = PlaybackService(resolve: library.resolve);
  await SystemMediaHandler.start(
    playback: playback,
    fallbackArtwork: await _writeFallbackArtwork(),
  );

  runApp(
    MediaPlayerApp(playback: playback, history: history, library: library),
  );
}

/// The system media controls need artwork as a file, so the app icon is copied out of the assets.
Future<Uri?> _writeFallbackArtwork() async {
  try {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'now_playing_artwork.png'));
    if (!await file.exists()) {
      final data = await rootBundle.load('assets/icon/app_icon.png');
      await file.create(recursive: true);
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }
    return file.uri;
  } on Exception catch (error) {
    debugPrint('[now playing] artwork not available: $error');
    return null;
  }
}

class MediaPlayerApp extends StatelessWidget {
  const MediaPlayerApp({
    super.key,
    required this.playback,
    required this.history,
    required this.library,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final MediaLibrary library;

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
      home: PlayerScreen(
        playback: playback,
        history: history,
        library: library,
      ),
    );
  }
}
