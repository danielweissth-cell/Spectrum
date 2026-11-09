import 'dart:async';
import 'dart:io';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_info.dart';
import 'history/history_store.dart';
import 'l10n/app_localizations.dart';
import 'library/media_library.dart';
import 'playback/playback_service.dart';
import 'playback/system_media_handler.dart';
import 'settings/app_settings.dart';
import 'ui/glass/glass.dart';
import 'ui/player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Not awaited: startup should not wait for shaders; the first frame or two use plain blur.
  unawaited(precacheGlass());

  final library = MediaLibrary();
  final history = HistoryStore();
  final settings = AppSettings();
  await Future.wait([library.load(), history.load(), settings.load()]);

  final playback = PlaybackService(resolve: library.resolve);
  await _applySoundSettings(settings, playback);
  settings.addListener(() => _applySoundSettings(settings, playback));
  await SystemMediaHandler.start(
    playback: playback,
    fallbackArtwork: await _writeFallbackArtwork(),
    // Created before any widget exists, so the text is looked up for the system language directly.
    notificationChannelName: lookupAppLocalizations(
      settings.language.locale ?? _supportedSystemLocale(),
    ).notificationChannelName,
  );

  runApp(
    MediaPlayerApp(
      playback: playback,
      history: history,
      library: library,
      settings: settings,
    ),
  );
}

/// Volume and speed are player-wide in libmpv, so they carry over to every next item.
Future<void> _applySoundSettings(
  AppSettings settings,
  PlaybackService playback,
) async {
  final player = playback.player;
  if (player.state.volume != settings.volume * 100) {
    await playback.setVolumeGain(settings.volume);
  }
  if (player.state.rate != settings.speed) {
    await playback.setSpeed(settings.speed);
  }
}

/// The system language if the app is translated into it, English otherwise.
Locale _supportedSystemLocale() {
  final systemLocale = PlatformDispatcher.instance.locale;
  return AppLocalizations.supportedLocales.firstWhere(
    (locale) => locale.languageCode == systemLocale.languageCode,
    orElse: () => const Locale('en'),
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
    required this.settings,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final MediaLibrary library;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: settings, builder: _buildApp);
  }

  Widget _buildApp(BuildContext context, Widget? _) {
    return MaterialApp(
      title: appName,
      locale: settings.language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Above the navigator, so the settings screen and dialogs see it too.
      builder: (context, child) =>
          GlassScope(enabled: settings.glassEnabled, child: child!),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A6EB1),
          brightness: Brightness.dark,
        ),
      ),
      home: PlayerScreen(
        playback: playback,
        history: history,
        library: library,
        settings: settings,
      ),
    );
  }
}
