/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:und_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:und_app/features/auth/presentation/providers/auth_provider.dart'
    as auth_present;
import 'package:und_app/features/inventory/providers/inventory_movement_providers.dart';
import 'package:und_app/features/shared/models/app_modules.dart';
import 'package:und_app/main.dart';

import 'firebase_mock_util.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // No Firebase initialization for test
  });

  group('Inventory Module Navigation', () {
    testWidgets('Navigate to Inventory module from Home and all its screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            auth_present.authRepositoryProvider
                .overrideWithValue(MockAuthRepository()),
            firestoreProvider.overrideWithValue(MockFirestore()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Inventory module card by icon
      final inventoryModule = appModules['inventory'];
      expect(inventoryModule, isNotNull);
      final inventoryIcon = find.byIcon(inventoryModule!.icon);
      expect(inventoryIcon, findsWidgets);
      await tester.tap(inventoryIcon.first);
      await tester.pumpAndSettle();

      // If there are multiple screens, a modal should open
      if (inventoryModule.screens.length > 1) {
        for (final screen in inventoryModule.screens) {
          // Find the screen by its nameKey (localized text may be used in real app)
          final screenText =
              find.textContaining(screen.nameKey, findRichText: true);
          expect(screenText, findsWidgets);
          await tester.tap(screenText.first);
          await tester.pumpAndSettle();

          // Check that the screen is displayed by route key
          expect(find.byKey(ValueKey(screen.route)), findsOneWidget);

          // Go back to home
          await tester.pageBack();
          await tester.pumpAndSettle();

          // Re-open the inventory module modal if needed
          await tester.tap(inventoryIcon.first);
          await tester.pumpAndSettle();
        }
      } else {
        // If only one screen, check it is displayed
        final screen = inventoryModule.screens.first;
        expect(find.byKey(ValueKey(screen.route)), findsOneWidget);
      }
    });
  });
}
*/
