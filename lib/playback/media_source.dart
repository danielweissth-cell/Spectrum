import 'package:path/path.dart' as p;

/// Helpers for media references.
///
/// A reference is what the app stores (history, queue extras). It is one of:
/// - a network URL (`https://...`);
/// - a file in the app library (`library:song.mp3`), resolved at play time because
///   the iOS app container path changes between installs;
/// - an absolute local path (desktop, where files are played in place).
abstract final class MediaSource {
  static const Set<String> networkSchemes = {'http', 'https', 'rtsp', 'rtmp'};
  static const String libraryScheme = 'library';

  static const Set<String> audioExtensions = {
    'mp3', 'm4a', 'aac', 'flac', 'wav', 'ogg', 'oga', 'opus', 'wma', //
    'aif', 'aiff', 'alac', 'ape', 'mka',
  };
  static const Set<String> videoExtensions = {
    'mp4', 'm4v', 'mov', 'mkv', 'webm', 'avi', 'wmv', 'flv', 'ts', //
    'm2ts', 'mts', '3gp', 'mpg', 'mpeg', 'ogv', 'vob',
  };

  /// Returns the parsed link, or null if [text] is not a supported network URL.
  static Uri? tryParseNetwork(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null || uri.host.isEmpty) return null;
    if (!networkSchemes.contains(uri.scheme.toLowerCase())) return null;
    return uri;
  }

  static String libraryReference(String fileName) => '$libraryScheme:$fileName';

  static bool isLibrary(String reference) =>
      reference.startsWith('$libraryScheme:');

  static bool isNetwork(String reference) => tryParseNetwork(reference) != null;

  static bool isLocal(String reference) => !isNetwork(reference);

  /// File name of a library reference.
  static String libraryFileName(String reference) =>
      reference.substring(libraryScheme.length + 1);

  static bool isMediaFileName(String fileName) {
    final extension = _extensionOf(fileName);
    return audioExtensions.contains(extension) ||
        videoExtensions.contains(extension);
  }

  static bool isVideoFileName(String fileName) =>
      videoExtensions.contains(_extensionOf(fileName));

  static String _extensionOf(String fileName) =>
      p.extension(fileName).replaceFirst('.', '').toLowerCase();

  /// Short human-readable name: the file name, or the host if the URL has no path.
  static String displayName(String reference) {
    if (isLibrary(reference)) return libraryFileName(reference);
    final uri = Uri.tryParse(reference);
    if (uri == null || !isNetwork(reference)) return p.basename(reference);
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? uri.host : Uri.decodeComponent(segments.last);
  }

  /// Where the media comes from: the host for links, null for local files.
  static String? host(String reference) =>
      isNetwork(reference) ? Uri.parse(reference).host : null;
}
