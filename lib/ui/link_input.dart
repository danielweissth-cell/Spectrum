import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../playback/media_source.dart';
import 'style/style_look.dart';

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
    final look = StyleLook.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.actionOpenFile,
            color: look.foreground,
            icon: const Icon(Icons.folder_open),
            onPressed: widget.onOpenFiles,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.go,
              style: TextStyle(color: look.foreground),
              cursorColor: look.foreground,
              decoration: InputDecoration(
                hintText: l10n.linkFieldLabel,
                hintStyle: TextStyle(color: look.foregroundMuted),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _submit(widget.onPlay),
            ),
          ),
          IconButton(
            tooltip: l10n.actionAddToQueue,
            color: look.foreground,
            icon: const Icon(Icons.playlist_add),
            onPressed: () => _submit(widget.onEnqueue),
          ),
          IconButton.filled(
            tooltip: l10n.actionPlay,
            style: IconButton.styleFrom(
              backgroundColor: look.accent,
              foregroundColor: look.onAccent,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(look.radius(24)),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _submit(widget.onPlay),
          ),
        ],
      ),
    );
  }
}
