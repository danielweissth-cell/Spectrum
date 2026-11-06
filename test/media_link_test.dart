import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/playback/media_link.dart';

void main() {
  group('MediaLink.tryParse', () {
    test('accepts http, https and streaming schemes', () {
      expect(MediaLink.tryParse(' https://example.com/a.mp3 '), isNotNull);
      expect(MediaLink.tryParse('http://example.com/live.m3u8'), isNotNull);
      expect(MediaLink.tryParse('rtsp://camera.local/stream'), isNotNull);
    });

    test('rejects text without a host or with an unsupported scheme', () {
      expect(MediaLink.tryParse('example'), isNull);
      expect(MediaLink.tryParse('file:///etc/passwd'), isNull);
      expect(MediaLink.tryParse('javascript:alert(1)'), isNull);
    });
  });

  group('MediaLink.displayName', () {
    test('uses the last path segment', () {
      expect(MediaLink.displayName('https://a.com/music/song.mp3'), 'song.mp3');
    });

    test('falls back to the host', () {
      expect(
        MediaLink.displayName('https://radio.example.com/'),
        'radio.example.com',
      );
    });
  });
}
