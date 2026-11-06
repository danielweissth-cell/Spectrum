import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../playback/media_link.dart';
import '../playback/playback_service.dart';

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
          return const _EmptyHint(
            text: 'The queue is empty.\nAdd a link with the queue button.',
          );
        }
        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: playlist.medias.length,
          onReorderItem: playback.move,
          itemBuilder: (context, index) {
            final url = playlist.medias[index].uri;
            final isCurrent = index == playlist.index;
            return Dismissible(
              key: ValueKey('$index|$url'),
              direction: DismissDirection.endToStart,
              background: const _DeleteBackground(),
              onDismissed: (_) => playback.removeAt(index),
              child: ListTile(
                selected: isCurrent,
                leading: isCurrent
                    ? const Icon(Icons.graphic_eq)
                    : Text('${index + 1}'),
                title: Text(
                  MediaLink.displayName(url),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(MediaLink.host(url), maxLines: 1),
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

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
