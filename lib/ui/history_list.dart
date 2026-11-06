import 'package:flutter/material.dart';

import '../history/history_store.dart';
import '../playback/media_link.dart';

/// Recently played links: tap to play, button to queue, swipe to forget.
class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.history,
    required this.onPlay,
    required this.onEnqueue,
  });

  final HistoryStore history;
  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await history.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final urls = history.urls;
        if (urls.isEmpty) {
          return Center(
            child: Text(
              'Links you play will appear here.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          );
        }
        return ListView.builder(
          itemCount: urls.length + 1,
          itemBuilder: (context, index) {
            if (index == urls.length) {
              return Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear history'),
                  onPressed: () => _confirmClear(context),
                ),
              );
            }
            final url = urls[index];
            return Dismissible(
              key: ValueKey(url),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Theme.of(context).colorScheme.errorContainer,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Icon(Icons.delete),
              ),
              onDismissed: (_) => history.remove(url),
              child: ListTile(
                title: Text(
                  MediaLink.displayName(url),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Add to queue',
                  icon: const Icon(Icons.playlist_add),
                  onPressed: () => onEnqueue(url),
                ),
                onTap: () => onPlay(url),
              ),
            );
          },
        );
      },
    );
  }
}
