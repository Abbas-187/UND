import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/features/shared/models/app_modules.dart';
import 'package:und_app/firebase_options.dart';
import 'package:und_app/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  });

  group('Module tiles navigation', () {
    testWidgets('tapping each module tile navigates correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));
      for (final module in appModules.values) {
        // Verify tile exists
        expect(find.byIcon(module.icon), findsOneWidget);
        await tester.tap(find.byIcon(module.icon));
        await tester.pumpAndSettle();
        // Assert landing on first screen of module
        final firstScreenRoute = module.screens.first.route;
        expect(find.byKey(ValueKey(firstScreenRoute)), findsOneWidget);
        // Navigate back
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });
  });

  group('Module screens navigation', () {
    testWidgets(
        'tapping each module tile and all its screens navigates correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));
      for (final module in appModules.values) {
        // Tap the module tile
        expect(find.byIcon(module.icon), findsOneWidget);
        await tester.tap(find.byIcon(module.icon));
        await tester.pumpAndSettle();
        // For each screen in the module
        for (final screen in module.screens) {
          // If there is a screen selection UI, tap the screen option
          if (module.screens.length > 1) {
            // Open the screen selection modal if not already open
            if (find.text(screen.nameKey).evaluate().isEmpty) {
              // Tap again to open modal
              await tester.tap(find.byIcon(module.icon));
              await tester.pumpAndSettle();
            }
            // Tap the screen in the modal
            expect(find.text(screen.nameKey), findsWidgets);
            await tester.tap(find.text(screen.nameKey).first);
            await tester.pumpAndSettle();
          }
          // Assert landing on the screen (by ValueKey or other unique identifier)
          expect(find.byKey(ValueKey(screen.route)), findsOneWidget);
          // Navigate back to module selection/home
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        // After all screens, go back to home if not already there
        if (find.byIcon(module.icon).evaluate().isEmpty) {
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
