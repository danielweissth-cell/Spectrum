import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_player/main.dart' as app;
import 'package:media_player/ui/glass/glass.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  bool glassOnMainScreen(WidgetTester tester) {
    final panel = find.byType(GlassPanel).first;
    return GlassScope.enabledOf(tester.element(panel));
  }

  testWidgets('the Liquid Glass switch changes the main screen at once', (
    tester,
  ) async {
    app.main();
    // main() loads the library, history and settings before the first frame.
    for (
      var i = 0;
      i < 100 && find.byType(GlassPanel).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(glassOnMainScreen(tester), isTrue);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    // Time to take a screenshot from outside.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 8)),
    );
    await tester.pump();
    expect(glassOnMainScreen(tester), isFalse);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(glassOnMainScreen(tester), isTrue);
  });
}
