import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../playback/media_source.dart';

/// Media files stored inside the app (phones only).
///
/// On iOS the folder is the app Documents directory, which the Files app shows
/// as "On My iPhone > Spectrum", so the user can also add files there directly.
/// On desktop files are played where they are, and the library is not used.
class MediaLibrary extends ChangeNotifier {
  /// Whether picked files are moved into the library. Phone pickers only hand out
  /// temporary copies, so keeping them is the only way to replay them later.
  static bool get importsFiles => Platform.isIOS || Platform.isAndroid;

  Directory? _directory;
  List<String> _fileNames = const [];

  /// Media file names in the library, sorted alphabetically.
  List<String> get fileNames => _fileNames;

  Future<void> load() async {
    if (!importsFiles) return;
    final documents = await getApplicationDocumentsDirectory();
    // Android keeps the documents directory private, so a subfolder keeps it tidy.
    _directory = Platform.isIOS
        ? documents
        : Directory(p.join(documents.path, 'Media'));
    await _directory!.create(recursive: true);
    await refresh();
  }

  /// Re-reads the folder, for example after the user added files through the Files app.
  Future<void> refresh() async {
    final directory = _directory;
    if (directory == null) return;
    final names = <String>[];
    await for (final entity in directory.list()) {
      final name = p.basename(entity.path);
      if (entity is File && MediaSource.isMediaFileName(name)) names.add(name);
    }
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _fileNames = List.unmodifiable(names);
    notifyListeners();
  }

  /// Turns a stored reference into something libmpv can open.
  String resolve(String reference) {
    if (!MediaSource.isLibrary(reference)) return reference;
    final directory = _directory;
    final fileName = MediaSource.libraryFileName(reference);
    return directory == null ? fileName : p.join(directory.path, fileName);
  }

  /// Whether a local reference still points to an existing file. Links always count as available.
  bool isAvailable(String reference) {
    if (MediaSource.isNetwork(reference)) return true;
    return File(resolve(reference)).existsSync();
  }

  /// Moves a picked temporary file into the library and returns its reference.
  Future<String> import(String temporaryPath) async {
    final directory = _directory;
    if (directory == null) return temporaryPath;
    final target = _uniquePath(directory, p.basename(temporaryPath));
    final source = File(temporaryPath);
    try {
      // Same volume on iOS, so this is instant even for large videos.
      await source.rename(target);
    } on FileSystemException {
      await source.copy(target);
      await source.delete();
    }
    await refresh();
    return MediaSource.libraryReference(p.basename(target));
  }

  Future<void> delete(String reference) async {
    final file = File(resolve(reference));
    if (await file.exists()) await file.delete();
    await refresh();
  }

  static String _uniquePath(Directory directory, String fileName) {
    final base = p.basenameWithoutExtension(fileName);
    final extension = p.extension(fileName);
    var candidate = p.join(directory.path, fileName);
    for (var copy = 2; File(candidate).existsSync(); copy++) {
      candidate = p.join(directory.path, '$base ($copy)$extension');
    }
    return candidate;
  }
}
