import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/playback/media_source.dart';

void main() {
  group('MediaSource.tryParseNetwork', () {
    test('accepts http, https and streaming schemes', () {
      expect(
        MediaSource.tryParseNetwork(' https://example.com/a.mp3 '),
        isNotNull,
      );
      expect(
        MediaSource.tryParseNetwork('http://example.com/live.m3u8'),
        isNotNull,
      );
      expect(
        MediaSource.tryParseNetwork('rtsp://camera.local/stream'),
        isNotNull,
      );
    });

    test('rejects text without a host or with an unsupported scheme', () {
      expect(MediaSource.tryParseNetwork('example'), isNull);
      expect(MediaSource.tryParseNetwork('file:///etc/passwd'), isNull);
      expect(MediaSource.tryParseNetwork('javascript:alert(1)'), isNull);
    });
  });

  group('MediaSource.displayName', () {
    test('uses the decoded last path segment of a link', () {
      expect(
        MediaSource.displayName('https://a.com/music/my%20song.mp3'),
        'my song.mp3',
      );
    });

    test('falls back to the host', () {
      expect(
        MediaSource.displayName('https://radio.example.com/'),
        'radio.example.com',
      );
    });

    test('uses the file name of library and local files', () {
      expect(MediaSource.displayName('library:Movie.mkv'), 'Movie.mkv');
      expect(MediaSource.displayName('/home/user/Music/a.flac'), 'a.flac');
    });
  });

  test('library references round-trip and are local', () {
    final reference = MediaSource.libraryReference('clip.mp4');
    expect(MediaSource.isLibrary(reference), isTrue);
    expect(MediaSource.isLocal(reference), isTrue);
    expect(MediaSource.libraryFileName(reference), 'clip.mp4');
    expect(MediaSource.host(reference), isNull);
  });

  test('recognises media file extensions case-insensitively', () {
    expect(MediaSource.isMediaFileName('A.MP3'), isTrue);
    expect(MediaSource.isMediaFileName('clip.mkv'), isTrue);
    expect(MediaSource.isMediaFileName('notes.pdf'), isFalse);
  });
}
