import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/l10n/app_localizations.dart';

void main() {
  test('English and Russian are supported', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      containsAll(['en', 'ru']),
    );
  });

  test('Russian texts are translated and keep their arguments', () {
    final russian = lookupAppLocalizations(const Locale('ru'));
    expect(russian.tabQueue, 'Очередь');
    expect(russian.playbackFailedNamed('song.mp3'), contains('song.mp3'));
    expect(russian.notMediaFiles(2, 'a.pdf, b.txt'), contains('a.pdf, b.txt'));
    expect(russian.libraryDeleteMessage('clip.mp4'), contains('clip.mp4'));
  });

  test('English plural forms differ for one and many files', () {
    final english = lookupAppLocalizations(const Locale('en'));
    expect(english.notMediaFiles(1, 'a.pdf'), startsWith('Not an audio'));
    expect(english.notMediaFiles(2, 'a.pdf, b.txt'), startsWith('Not audio'));
  });
}
