import 'package:flutter/material.dart';

/// Centered hint shown instead of an empty list.
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.text, this.scrollable = false});

  final String text;

  /// Needed inside [RefreshIndicator], which only works with a scrollable child.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final hint = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
    if (!scrollable) return hint;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: hint,
        ),
      ),
    );
  }
}

/// Red background revealed when a list row is swiped to delete it.
class DeleteBackground extends StatelessWidget {
  const DeleteBackground({super.key});

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
