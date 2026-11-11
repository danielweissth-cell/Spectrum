import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_player/l10n/app_localizations.dart';
import 'package:media_player/main.dart' as app;
import 'package:media_player/settings/app_settings.dart';
import 'package:media_player/ui/glass/glass.dart';
import 'package:media_player/ui/style/style_look.dart';

// One scenario: the app can start only once per run, because the system media
// session cannot be registered twice.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, Duration duration) async {
    await tester.runAsync(() => Future<void>.delayed(duration));
    await tester.pump();
  }

  /// Leaves the screen still for a while, so a screenshot can be taken from outside.
  Future<void> pauseForScreenshot(WidgetTester tester) =>
      wait(tester, const Duration(seconds: 8));

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> closeSettings(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  BuildContext topScreen(WidgetTester tester) =>
      tester.element(find.byType(Scaffold).last);

  bool glassOnMainScreen(WidgetTester tester) =>
      GlassScope.enabledOf(tester.element(find.byType(GlassPanel).first));

  testWidgets('settings change the app at once', (tester) async {
    app.main();
    // main() loads the library, history and settings before the first frame.
    for (
      var i = 0;
      i < 100 && find.byType(GlassPanel).evaluate().isEmpty;
      i++
    ) {
      await wait(tester, const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    // Liquid Glass switch.
    expect(glassOnMainScreen(tester), isTrue);
    await openSettings(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await closeSettings(tester);
    expect(glassOnMainScreen(tester), isFalse);
    await openSettings(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await closeSettings(tester);
    expect(glassOnMainScreen(tester), isTrue);

    // Style tiles.
    await openSettings(tester);
    final l10n = AppLocalizations.of(topScreen(tester));
    final names = {
      AppStyle.rainbow: l10n.styleRainbow,
      AppStyle.bit64: l10n.style64Bit,
      AppStyle.dark: l10n.styleDark,
      AppStyle.white: l10n.styleWhite,
    };
    final previous = StyleLook.of(topScreen(tester)).style;
    for (final style in [AppStyle.bit64, AppStyle.white, previous]) {
      await tester.tap(find.text(names[style]!));
      await tester.pumpAndSettle();
      expect(StyleLook.of(topScreen(tester)).style, style);
      if (style != previous) await pauseForScreenshot(tester);
    }
    await closeSettings(tester);
  });
}
