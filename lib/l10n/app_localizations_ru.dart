// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tabQueue => 'Очередь';

  @override
  String get tabLibrary => 'Файлы';

  @override
  String get tabHistory => 'История';

  @override
  String get linkFieldLabel => 'Вставьте ссылку';

  @override
  String get linkInvalid => 'Введите полную ссылку, например https://...';

  @override
  String get actionOpenFile => 'Открыть файл';

  @override
  String get actionAddToQueue => 'Добавить в очередь';

  @override
  String get actionPlay => 'Воспроизвести';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionClear => 'Очистить';

  @override
  String get pickSourceFiles => 'Файлы';

  @override
  String get pickSourceFilesHint => 'Музыка и видео из приложения «Файлы»';

  @override
  String get pickSourcePhotos => 'Галерея';

  @override
  String get pickSourcePhotosHint => 'Видео из вашей галереи';

  @override
  String get pickDialogTitle => 'Открыть медиафайл';

  @override
  String get addedToQueue => 'Добавлено в очередь';

  @override
  String get onThisDevice => 'На этом устройстве';

  @override
  String get fileMissing => 'Этого файла больше нет на устройстве.';

  @override
  String notMediaFiles(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Это не аудио и не видео: $names',
      many: 'Это не аудио и не видео: $names',
      few: 'Это не аудио и не видео: $names',
      one: 'Это не аудио и не видео: $names',
    );
    return '$_temp0';
  }

  @override
  String playbackFailedNamed(String name) {
    return 'Не удалось воспроизвести $name. Проверьте ссылку и подключение к интернету.';
  }

  @override
  String get playbackFailed =>
      'Не удалось воспроизвести. Проверьте ссылку и подключение к интернету.';

  @override
  String get queueEmpty =>
      'Очередь пуста.\nДобавьте ссылку или файл кнопкой очереди.';

  @override
  String get historyEmpty =>
      'Здесь появятся ссылки и файлы, которые вы включали.';

  @override
  String get historyClearTitle => 'Очистить историю?';

  @override
  String get historyClearAction => 'Очистить историю';

  @override
  String get libraryEmptyIos =>
      'Файлов пока нет.\nОткройте файл кнопкой с папкой или скопируйте файлы в «На iPhone → Spectrum» в приложении «Файлы».';

  @override
  String get libraryEmpty =>
      'Файлов пока нет.\nОткройте файл кнопкой с папкой.';

  @override
  String get libraryDeleteTitle => 'Удалить файл?';

  @override
  String libraryDeleteMessage(String fileName) {
    return 'Файл «$fileName» будет удалён с устройства.';
  }

  @override
  String get notificationChannelName => 'Воспроизведение';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Как в системе';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsGlass => 'Liquid Glass';

  @override
  String get settingsGlassHint => 'Выключите, чтобы экономить батарею';

  @override
  String get settingsSound => 'Звук';

  @override
  String get settingsVolume => 'Громкость';

  @override
  String get settingsVolumeHint => 'Выше 2× звук может хрипеть';

  @override
  String get settingsSpeed => 'Скорость';

  @override
  String settingsMultiplier(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString×';
  }

  @override
  String get settingsReset => 'Сбросить';

  @override
  String get styleRainbow => 'Радуга';

  @override
  String get style64Bit => '64 бит';

  @override
  String get styleDark => 'Тёмный';

  @override
  String get styleWhite => 'Светлый';
}
