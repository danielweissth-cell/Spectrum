import 'package:flutter/material.dart';

import '../playback/media_link.dart';

/// Text field for a network link with "add to queue" and "play" actions.
class LinkInput extends StatefulWidget {
  const LinkInput({super.key, required this.onPlay, required this.onEnqueue});

  final ValueChanged<String> onPlay;
  final ValueChanged<String> onEnqueue;

  @override
  State<LinkInput> createState() => _LinkInputState();
}

class _LinkInputState extends State<LinkInput> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(ValueChanged<String> action) {
    final uri = MediaLink.tryParse(_controller.text);
    if (uri == null) {
      setState(() => _errorText = 'Enter a full link, for example https://...');
      return;
    }
    setState(() => _errorText = null);
    _controller.clear();
    FocusScope.of(context).unfocus();
    action(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              labelText: 'Link to audio or video',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(widget.onPlay),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.outlined(
            tooltip: 'Add to queue',
            icon: const Icon(Icons.playlist_add),
            onPressed: () => _submit(widget.onEnqueue),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.filled(
            tooltip: 'Play',
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _submit(widget.onPlay),
          ),
        ),
      ],
    );
  }
}
