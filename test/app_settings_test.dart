import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/l10n/app_localizations.dart';
import 'package:media_player/settings/app_settings.dart';
import 'package:media_player/ui/style/style_look.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('defaults are used on the first launch', () async {
    final settings = AppSettings();
    await settings.load();
    expect(settings.language, AppLanguage.system);
    expect(settings.glassEnabled, isTrue);
    expect(settings.volume, AppSettings.defaultVolume);
    expect(settings.speed, AppSettings.defaultSpeed);
    expect(settings.style, AppStyle.dark);
  });

  test('changes survive a restart', () async {
    final settings = AppSettings();
    await settings.load();
    await settings.setLanguage(AppLanguage.russian);
    await settings.setGlassEnabled(false);
    await settings.setVolume(2.5);
    await settings.setSpeed(1.25);
    await settings.setStyle(AppStyle.bit64);

    final restarted = AppSettings();
    await restarted.load();
    expect(restarted.language, AppLanguage.russian);
    expect(restarted.glassEnabled, isFalse);
    expect(restarted.volume, 2.5);
    expect(restarted.speed, 1.25);
    expect(restarted.style, AppStyle.bit64);
  });

  test('volume and speed stay within their ranges', () async {
    final settings = AppSettings();
    await settings.load();
    await settings.setVolume(9);
    await settings.setSpeed(0.1);
    expect(settings.volume, AppSettings.maxVolume);
    expect(settings.speed, AppSettings.minSpeed);
  });

  test('factors use the decimal separator of the language', () {
    expect(
      lookupAppLocalizations(const Locale('en')).settingsMultiplier(1.5),
      '1.5×',
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).settingsMultiplier(1.5),
      '1,5×',
    );
  });

  test('every style has a theme with its look attached', () {
    for (final style in AppStyle.values) {
      final theme = StyleLook.themeFor(style);
      expect(theme.extension<StyleLook>()?.style, style);
    }
    expect(StyleLook.themeFor(AppStyle.white).brightness, Brightness.light);
    expect(
      StyleLook.themeFor(AppStyle.bit64).textTheme.bodyMedium?.fontFamily,
      StyleLook.pixelFontFamily,
    );
    final pixelTheme = StyleLook.themeFor(AppStyle.bit64);
    expect(
      pixelTheme.textTheme.bodyMedium?.fontSize,
      lessThan(pixelTheme.typography.englishLike.bodyMedium!.fontSize!),
    );
  });
}
