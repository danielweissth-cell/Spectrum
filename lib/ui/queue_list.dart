import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../playback/media_source.dart';
import '../playback/playback_service.dart';
import 'list_parts.dart';

/// The play queue: tap to jump, drag to reorder, swipe to remove.
class QueueList extends StatelessWidget {
  const QueueList({super.key, required this.playback});

  final PlaybackService playback;

  @override
  Widget build(BuildContext context) {
    final player = playback.player;
    return StreamBuilder<Playlist>(
      stream: player.stream.playlist,
      initialData: player.state.playlist,
      builder: (context, snapshot) {
        final playlist = snapshot.data ?? const Playlist([]);
        if (playlist.medias.isEmpty) {
          return const EmptyHint(
            text: 'The queue is empty.\nAdd a link or a file with the queue button.',
          );
        }
        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: playlist.medias.length,
          onReorderItem: playback.move,
          itemBuilder: (context, index) {
            final reference = PlaybackService.referenceOf(
              playlist.medias[index],
            );
            final isCurrent = index == playlist.index;
            return Dismissible(
              key: ValueKey('$index|$reference'),
              direction: DismissDirection.endToStart,
              background: const DeleteBackground(),
              onDismissed: (_) => playback.removeAt(index),
              child: ListTile(
                selected: isCurrent,
                leading: isCurrent
                    ? const Icon(Icons.graphic_eq)
                    : Text('${index + 1}'),
                title: Text(
                  MediaSource.displayName(reference),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  MediaSource.host(reference) ?? 'On this device',
                  maxLines: 1,
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                onTap: () => playback.jumpTo(index),
              ),
            );
          },
        );
      },
    );
  }
}
