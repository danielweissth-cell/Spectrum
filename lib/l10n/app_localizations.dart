import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @tabQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get tabQueue;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @linkFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get linkFieldLabel;

  /// No description provided for @linkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a full link, for example https://...'**
  String get linkInvalid;

  /// No description provided for @actionOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get actionOpenFile;

  /// No description provided for @actionAddToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get actionAddToQueue;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @pickSourceFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get pickSourceFiles;

  /// No description provided for @pickSourceFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Music and video from the Files app'**
  String get pickSourceFilesHint;

  /// No description provided for @pickSourcePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get pickSourcePhotos;

  /// No description provided for @pickSourcePhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Videos from your gallery'**
  String get pickSourcePhotosHint;

  /// No description provided for @pickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Open media'**
  String get pickDialogTitle;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// No description provided for @onThisDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get onThisDevice;

  /// No description provided for @fileMissing.
  ///
  /// In en, this message translates to:
  /// **'This file is no longer on the device.'**
  String get fileMissing;

  /// Shown when the user picked files that cannot be played. names is a comma-separated list of file names.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Not an audio or video file: {names}} other{Not audio or video files: {names}}}'**
  String notMediaFiles(int count, String names);

  /// No description provided for @playbackFailedNamed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play {name}. Check the link and your internet connection.'**
  String playbackFailedNamed(String name);

  /// No description provided for @playbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play this item. Check the link and your internet connection.'**
  String get playbackFailed;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty.\nAdd a link or a file with the queue button.'**
  String get queueEmpty;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Links and files you play will appear here.'**
  String get historyEmpty;

  /// No description provided for @historyClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get historyClearTitle;

  /// No description provided for @historyClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get historyClearAction;

  /// No description provided for @libraryEmptyIos.
  ///
  /// In en, this message translates to:
  /// **'No files yet.\nOpen a file with the folder button, or copy files to On My iPhone > Spectrum in the Files app.'**
  String get libraryEmptyIos;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No files yet.\nOpen a file with the folder button.'**
  String get libraryEmpty;

  /// No description provided for @libraryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete file?'**
  String get libraryDeleteTitle;

  /// No description provided for @libraryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" will be removed from this device.'**
  String libraryDeleteMessage(String fileName);

  /// Android notification channel shown in the system notification settings.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get notificationChannelName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// Always written in English, so it can be found in any language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Always written in Russian, so it can be found in any language.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsGlass.
  ///
  /// In en, this message translates to:
  /// **'Liquid Glass'**
  String get settingsGlass;

  /// No description provided for @settingsGlassHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off to save battery'**
  String get settingsGlassHint;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsVolumeHint.
  ///
  /// In en, this message translates to:
  /// **'Above 2× the sound may distort'**
  String get settingsVolumeHint;

  /// No description provided for @settingsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get settingsSpeed;

  /// A volume or speed factor, for example 1.5×.
  ///
  /// In en, this message translates to:
  /// **'{value}×'**
  String settingsMultiplier(double value);

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
