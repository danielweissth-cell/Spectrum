import 'dart:async';

import 'package:flutter/material.dart';

import '../app_info.dart';
import '../history/history_store.dart';
import '../library/media_library.dart';
import '../library/media_picker.dart';
import '../l10n/app_localizations.dart';
import '../playback/media_source.dart';
import '../playback/playback_service.dart';
import '../settings/app_settings.dart';
import 'glass/glass.dart';
import 'history_list.dart';
import 'library_list.dart';
import 'link_input.dart';
import 'queue_list.dart';
import 'settings_screen.dart';
import 'style/style_background.dart';
import 'style/style_look.dart';
import 'video_area.dart';

/// Main screen: video on top (or on the left in landscape), link input and lists below.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.playback,
    required this.history,
    required this.library,
    required this.settings,
  });

  final PlaybackService playback;
  final HistoryStore history;
  final MediaLibrary library;
  final AppSettings settings;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final StreamSubscription<String> _errorSubscription;
  late final MediaPicker _picker = MediaPicker(widget.library);

  @override
  void initState() {
    super.initState();
    _errorSubscription = widget.playback.player.stream.error.listen(
      _showPlaybackError,
    );
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// libmpv reports technical English text such as "Failed to open" followed by the address;
  /// the user gets a translated message with just the file or link name.
  void _showPlaybackError(String message) {
    debugPrint('[playback error] $message');
    const prefix = 'Failed to open ';
    final l10n = AppLocalizations.of(context);
    _showMessage(
      message.startsWith(prefix)
          ? l10n.playbackFailedNamed(
              MediaSource.displayName(message.substring(prefix.length).trim()),
            )
          : l10n.playbackFailed,
    );
  }

  /// A file played earlier may have been deleted since; forget it instead of failing in the player.
  bool _ensureAvailable(String reference) {
    if (widget.library.isAvailable(reference)) return true;
    widget.history.remove(reference);
    _showMessage(AppLocalizations.of(context).fileMissing);
    return false;
  }

  void _play(String reference) {
    if (!_ensureAvailable(reference)) return;
    widget.history.record(reference);
    widget.playback.playNow(reference);
  }

  void _enqueue(String reference) {
    if (!_ensureAvailable(reference)) return;
    widget.history.record(reference);
    widget.playback.enqueue(reference);
    _showMessage(AppLocalizations.of(context).addedToQueue);
  }

  Future<void> _delete(String reference) async {
    await widget.playback.removeReference(reference);
    await widget.history.remove(reference);
    await widget.library.delete(reference);
  }

  Future<void> _openFiles() async {
    final dialogTitle = AppLocalizations.of(context).pickDialogTitle;
    final source = MediaLibrary.importsFiles
        ? await _chooseSource()
        : MediaPickSource.files;
    if (source == null) return;
    final result = await _picker.pick(source, dialogTitle: dialogTitle);
    if (!mounted) return;
    if (result.rejectedNames.isNotEmpty) {
      _showMessage(
        AppLocalizations.of(context).notMediaFiles(
          result.rejectedNames.length,
          result.rejectedNames.join(', '),
        ),
      );
    }
    final references = result.references;
    if (references.isEmpty) return;
    // The first picked file starts now, the rest wait in the queue.
    _play(references.first);
    for (final reference in references.skip(1)) {
      widget.history.record(reference);
      await widget.playback.enqueue(reference);
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(settings: widget.settings),
      ),
    );
  }

  Future<MediaPickSource?> _chooseSource() {
    return showModalBottomSheet<MediaPickSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(AppLocalizations.of(context).pickSourceFiles),
              subtitle: Text(AppLocalizations.of(context).pickSourceFilesHint),
              onTap: () => Navigator.pop(context, MediaPickSource.files),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(AppLocalizations.of(context).pickSourcePhotos),
              subtitle: Text(AppLocalizations.of(context).pickSourcePhotosHint),
              onTap: () => Navigator.pop(context, MediaPickSource.photos),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showLibrary = MediaLibrary.importsFiles;
    final lists = TabBarView(
      children: [
        QueueList(playback: widget.playback),
        if (showLibrary)
          LibraryList(
            library: widget.library,
            onPlay: _play,
            onEnqueue: _enqueue,
            onDelete: _delete,
          ),
        HistoryList(
          history: widget.history,
          onPlay: _play,
          onEnqueue: _enqueue,
        ),
      ],
    );
    // The tab bar would sit on top of the keyboard otherwise.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return DefaultTabController(
      length: showLibrary ? 3 : 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(child: StyleBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final slots = _ScreenSlots.compute(constraints.biggest);
                  return Stack(
                    children: [
                      if (slots.title != null)
                        Positioned.fromRect(
                          rect: slots.title!,
                          child: const _Title(),
                        ),
                      Positioned.fromRect(
                        rect: slots.video,
                        child: _VideoCard(playback: widget.playback),
                      ),
                      Positioned.fromRect(
                        rect: slots.lists,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListTileTheme(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: _BottomInset(
                              inset: keyboardOpen
                                  ? 0
                                  : _ScreenSlots.tabBarHeight +
                                        _ScreenSlots.gap * 2,
                              child: lists,
                            ),
                          ),
                        ),
                      ),
                      // Painted last, so the glass refracts the video and the list below it.
                      Positioned.fill(
                        child: GlassLayer(
                          child: Stack(
                            children: [
                              Positioned.fromRect(
                                rect: slots.linkBar,
                                child: GlassPanel(
                                  radius: _ScreenSlots.linkBarHeight / 2,
                                  child: LinkInput(
                                    onPlay: _play,
                                    onEnqueue: _enqueue,
                                    onOpenFiles: _openFiles,
                                  ),
                                ),
                              ),
                              if (!keyboardOpen)
                                Positioned.fromRect(
                                  rect: slots.tabBar,
                                  child: _GlassTabBar(showLibrary: showLibrary),
                                ),
                              if (!keyboardOpen || slots.title != null)
                                Positioned.fromRect(
                                  rect: slots.settingsButton,
                                  child: _SettingsButton(
                                    onPressed: _openSettings,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where each part of the screen goes. The content and the glass layer above it are
/// laid out from the same rectangles, so the glass sits exactly over its place.
class _ScreenSlots {
  const _ScreenSlots({
    required this.title,
    required this.video,
    required this.linkBar,
    required this.lists,
    required this.tabBar,
    required this.settingsButton,
  });

  static const double margin = 16;
  static const double gap = 12;
  static const double titleHeight = 52;
  static const double linkBarHeight = 60;
  static const double tabBarHeight = 60;
  static const double tabBarMaxWidth = 380;
  static const double settingsButtonSize = 44;

  /// Null in landscape, where the screen is too short for a title.
  final Rect? title;
  final Rect video;
  final Rect linkBar;
  final Rect lists;
  final Rect tabBar;

  /// In the title row in portrait; next to the tab bar in landscape, where there is no title.
  final Rect settingsButton;

  factory _ScreenSlots.compute(Size size) {
    final isLandscape = size.width > size.height;
    if (isLandscape) {
      final panelLeft = size.width * 3 / 5;
      final panelWidth = size.width - panelLeft - margin;
      final settingsButton = Rect.fromLTWH(
        size.width - margin - tabBarHeight,
        size.height - gap - tabBarHeight,
        tabBarHeight,
        tabBarHeight,
      );
      final linkBar = Rect.fromLTWH(
        panelLeft,
        margin,
        panelWidth,
        linkBarHeight,
      );
      return _ScreenSlots(
        title: null,
        video: Rect.fromLTRB(
          margin,
          margin,
          panelLeft - gap,
          size.height - margin,
        ),
        linkBar: linkBar,
        lists: Rect.fromLTRB(
          panelLeft - margin,
          linkBar.bottom + gap / 2,
          size.width,
          size.height,
        ),
        tabBar: _tabBar(
          left: panelLeft,
          width: panelWidth - tabBarHeight - gap,
          bottom: size.height,
        ),
        settingsButton: settingsButton,
      );
    }
    final contentWidth = size.width - margin * 2;
    final video = Rect.fromLTWH(
      margin,
      titleHeight,
      contentWidth,
      contentWidth * 9 / 16,
    );
    final linkBar = Rect.fromLTWH(
      margin,
      video.bottom + gap,
      contentWidth,
      linkBarHeight,
    );
    return _ScreenSlots(
      title: Rect.fromLTWH(margin, 0, contentWidth, titleHeight),
      video: video,
      linkBar: linkBar,
      lists: Rect.fromLTRB(
        0,
        linkBar.bottom + gap / 2,
        size.width,
        size.height,
      ),
      tabBar: _tabBar(left: margin, width: contentWidth, bottom: size.height),
      settingsButton: Rect.fromLTWH(
        size.width - margin - settingsButtonSize,
        (titleHeight - settingsButtonSize) / 2,
        settingsButtonSize,
        settingsButtonSize,
      ),
    );
  }

  static Rect _tabBar({
    required double left,
    required double width,
    required double bottom,
  }) {
    final barWidth = width < tabBarMaxWidth ? width : tabBarMaxWidth;
    return Rect.fromLTWH(
      left + (width - barWidth) / 2,
      bottom - gap - tabBarHeight,
      barWidth,
      tabBarHeight,
    );
  }
}

/// Lets list rows scroll under the floating tab bar while the last row can still scroll above it.
class _BottomInset extends StatelessWidget {
  const _BottomInset({required this.inset, required this.child});

  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(bottom: inset),
      ),
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        appName,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: StyleLook.of(context).foreground,
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.playback});

  final PlaybackService playback;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(StyleLook.of(context).radius(24)),
      child: VideoArea(playback: playback),
    );
  }
}

/// Floating Liquid Glass capsule with the Queue / Library / History tabs.
class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({required this.showLibrary});

  final bool showLibrary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final look = StyleLook.of(context);
    final indicatorRadius = BorderRadius.circular(
      look.radius((_ScreenSlots.tabBarHeight - 12) / 2),
    );
    return GlassPanel(
      radius: _ScreenSlots.tabBarHeight / 2,
      floating: true,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: look.selection,
            borderRadius: indicatorRadius,
          ),
          splashBorderRadius: indicatorRadius,
          labelColor: look.foreground,
          unselectedLabelColor: look.foregroundMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: l10n.tabQueue),
            if (showLibrary) Tab(text: l10n.tabLibrary),
            Tab(text: l10n.tabHistory),
          ],
        ),
      ),
    );
  }
}

/// Round glass button that opens the settings.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GlassPanel(
        radius: constraints.maxHeight / 2,
        child: Center(
          child: IconButton(
            tooltip: AppLocalizations.of(context).settingsTitle,
            color: StyleLook.of(context).foreground,
            icon: const Icon(Icons.settings_outlined),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
