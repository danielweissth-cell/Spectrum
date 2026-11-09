// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabQueue => 'Queue';

  @override
  String get tabLibrary => 'Library';

  @override
  String get tabHistory => 'History';

  @override
  String get linkFieldLabel => 'Paste a link';

  @override
  String get linkInvalid => 'Enter a full link, for example https://...';

  @override
  String get actionOpenFile => 'Open file';

  @override
  String get actionAddToQueue => 'Add to queue';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClear => 'Clear';

  @override
  String get pickSourceFiles => 'Files';

  @override
  String get pickSourceFilesHint => 'Music and video from the Files app';

  @override
  String get pickSourcePhotos => 'Photo library';

  @override
  String get pickSourcePhotosHint => 'Videos from your gallery';

  @override
  String get pickDialogTitle => 'Open media';

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String get onThisDevice => 'On this device';

  @override
  String get fileMissing => 'This file is no longer on the device.';

  @override
  String notMediaFiles(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Not audio or video files: $names',
      one: 'Not an audio or video file: $names',
    );
    return '$_temp0';
  }

  @override
  String playbackFailedNamed(String name) {
    return 'Couldn\'t play $name. Check the link and your internet connection.';
  }

  @override
  String get playbackFailed =>
      'Couldn\'t play this item. Check the link and your internet connection.';

  @override
  String get queueEmpty =>
      'The queue is empty.\nAdd a link or a file with the queue button.';

  @override
  String get historyEmpty => 'Links and files you play will appear here.';

  @override
  String get historyClearTitle => 'Clear history?';

  @override
  String get historyClearAction => 'Clear history';

  @override
  String get libraryEmptyIos =>
      'No files yet.\nOpen a file with the folder button, or copy files to On My iPhone > Spectrum in the Files app.';

  @override
  String get libraryEmpty =>
      'No files yet.\nOpen a file with the folder button.';

  @override
  String get libraryDeleteTitle => 'Delete file?';

  @override
  String libraryDeleteMessage(String fileName) {
    return '\"$fileName\" will be removed from this device.';
  }

  @override
  String get notificationChannelName => 'Playback';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsGlass => 'Liquid Glass';

  @override
  String get settingsGlassHint => 'Turn off to save battery';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsVolumeHint => 'Above 2× the sound may distort';

  @override
  String get settingsSpeed => 'Speed';

  @override
  String settingsMultiplier(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString×';
  }

  @override
  String get settingsReset => 'Reset';
}
