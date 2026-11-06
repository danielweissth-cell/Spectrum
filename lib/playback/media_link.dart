/// Validation and display helpers for network media links.
abstract final class MediaLink {
  static const Set<String> supportedSchemes = {'http', 'https', 'rtsp', 'rtmp'};

  /// Returns the parsed link, or null if [text] is not a supported network URL.
  static Uri? tryParse(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null || uri.host.isEmpty) return null;
    if (!supportedSchemes.contains(uri.scheme.toLowerCase())) return null;
    return uri;
  }

  /// Short human-readable name: the last path segment, or the host if there is none.
  static String displayName(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? uri.host : segments.last;
  }

  static String host(String url) => Uri.tryParse(url)?.host ?? '';
}
