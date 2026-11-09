import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../playback/media_source.dart';

/// Single-line bar with a link field, "open file", "add to queue" and "play" buttons.
/// It has no background of its own: it sits inside a glass capsule.
class LinkInput extends StatefulWidget {
  const LinkInput({
    super.key,
    required this.onPlay,
    required this.onEnqueue,
    required this.onOpenFiles,
  });

  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;
  final VoidCallback onOpenFiles;

  @override
  State<LinkInput> createState() => _LinkInputState();
}

class _LinkInputState extends State<LinkInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(ValueChanged<String> action) {
    final uri = MediaSource.tryParseNetwork(_controller.text);
    if (uri == null) {
      // A message under the field would stretch the capsule, so the hint pops up instead.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkInvalid)),
        );
      return;
    }
    _controller.clear();
    FocusScope.of(context).unfocus();
    action(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.actionOpenFile,
            color: Colors.white,
            icon: const Icon(Icons.folder_open),
            onPressed: widget.onOpenFiles,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.go,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: l10n.linkFieldLabel,
                hintStyle: const TextStyle(color: Colors.white60),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _submit(widget.onPlay),
            ),
          ),
          IconButton(
            tooltip: l10n.actionAddToQueue,
            color: Colors.white,
            icon: const Icon(Icons.playlist_add),
            onPressed: () => _submit(widget.onEnqueue),
          ),
          IconButton.filled(
            tooltip: l10n.actionPlay,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2B2F6B),
            ),
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _submit(widget.onPlay),
          ),
        ],
      ),
    );
  }
}
