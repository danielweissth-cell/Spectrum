import 'package:flutter/material.dart';

import '../library/media_library.dart';
import '../playback/media_source.dart';
import 'list_parts.dart';

/// Files stored in the app: tap to play, button to queue, swipe to delete from the device.
class LibraryList extends StatefulWidget {
  const LibraryList({
    super.key,
    required this.library,
    required this.onPlay,
    required this.onEnqueue,
    required this.onDelete,
  });

  final MediaLibrary library;
  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;
  final ValueChanged<String> onDelete;

  @override
  State<LibraryList> createState() => _LibraryListState();
}

class _LibraryListState extends State<LibraryList> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Files may be added through the Files app while Spectrum is in the background.
    _lifecycleListener = AppLifecycleListener(onResume: widget.library.refresh);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text('"$fileName" will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.library,
      builder: (context, _) {
        final fileNames = widget.library.fileNames;
        return RefreshIndicator(
          onRefresh: widget.library.refresh,
          child: fileNames.isEmpty
              ? const EmptyHint(
                  scrollable: true,
                  text:
                      'No files yet.\nOpen a file with the folder button, or copy files '
                      'to On My iPhone > Spectrum in the Files app.',
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: fileNames.length,
                  itemBuilder: (context, index) {
                    final fileName = fileNames[index];
                    final reference = MediaSource.libraryReference(fileName);
                    return Dismissible(
                      key: ValueKey(reference),
                      direction: DismissDirection.endToStart,
                      background: const DeleteBackground(),
                      confirmDismiss: (_) => _confirmDelete(fileName),
                      onDismissed: (_) => widget.onDelete(reference),
                      child: ListTile(
                        leading: Icon(
                          MediaSource.isVideoFileName(fileName)
                              ? Icons.movie_outlined
                              : Icons.music_note_outlined,
                        ),
                        title: Text(
                          fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          tooltip: 'Add to queue',
                          icon: const Icon(Icons.playlist_add),
                          onPressed: () => widget.onEnqueue(reference),
                        ),
                        onTap: () => widget.onPlay(reference),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
