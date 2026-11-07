import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../playback/media_source.dart';
import 'media_library.dart';

/// Where the user wants to pick media from.
enum MediaPickSource {
  /// The system file browser (Files app on iOS).
  files,

  /// The photo library (videos only). Phones only.
  photos,
}

/// Outcome of a pick: references ready to play, and names of files that were not media.
class MediaPickResult {
  const MediaPickResult({
    required this.references,
    required this.rejectedNames,
  });

  final List<String> references;
  final List<String> rejectedNames;
}

/// Opens the system picker and turns picked files into playable references.
class MediaPicker {
  const MediaPicker(this.library);

  final MediaLibrary library;

  Future<MediaPickResult> pick(MediaPickSource source) async {
    final fromPhotos = source == MediaPickSource.photos;
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Open media',
      // Phone file browsers do not know types like MKV or Opus, so filtering happens below.
      type: fromPhotos
          ? FileType.video
          : MediaLibrary.importsFiles
          ? FileType.any
          : FileType.custom,
      allowedExtensions: !fromPhotos && !MediaLibrary.importsFiles
          ? [...MediaSource.audioExtensions, ...MediaSource.videoExtensions]
          : null,
    );

    final references = <String>[];
    final rejectedNames = <String>[];
    for (final file in files) {
      final path = file.path;
      final isMedia = fromPhotos || MediaSource.isMediaFileName(file.name);
      if (path == null || !isMedia) {
        rejectedNames.add(file.name);
        // A rejected temporary copy would otherwise stay in the app storage.
        if (path != null && MediaLibrary.importsFiles) {
          await _deleteQuietly(path);
        }
        continue;
      }
      references.add(
        MediaLibrary.importsFiles ? await library.import(path) : path,
      );
    }
    return MediaPickResult(
      references: references,
      rejectedNames: rejectedNames,
    );
  }

  static Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone; nothing to clean up.
    }
  }
}
