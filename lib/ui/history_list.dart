import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../history/history_store.dart';
import '../playback/media_source.dart';
import 'list_parts.dart';

/// Recently played links and files: tap to play, button to queue, swipe to forget.
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
        title: Text(AppLocalizations.of(context).historyClearTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).actionClear),
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
          return EmptyHint(text: AppLocalizations.of(context).historyEmpty);
        }
        return ListView.builder(
          itemCount: urls.length + 1,
          itemBuilder: (context, index) {
            if (index == urls.length) {
              return Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: Text(AppLocalizations.of(context).historyClearAction),
                  onPressed: () => _confirmClear(context),
                ),
              );
            }
            final url = urls[index];
            return Dismissible(
              key: ValueKey(url),
              direction: DismissDirection.endToStart,
              background: const DeleteBackground(),
              onDismissed: (_) => history.remove(url),
              child: ListTile(
                title: Text(
                  MediaSource.displayName(url),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  MediaSource.isNetwork(url)
                      ? url
                      : AppLocalizations.of(context).onThisDevice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: AppLocalizations.of(context).actionAddToQueue,
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
