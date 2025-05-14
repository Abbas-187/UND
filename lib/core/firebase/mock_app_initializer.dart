import 'package:flutter/material.dart';


/// Helper class to initialize the app with mock Firebase
class MockAppInitializer {
  /// Initialize the app with mock Firebase
  static Future<void> initializeMockFirebase() async {
    // No actual Firebase initialization needed - we're using mocks
    debugPrint('🔥 Using MOCK Firebase implementation');

    // You could initialize any preset data here
    // For example:
    // final container = ProviderContainer();
    // final firestoreInterface = container.read(firestoreInterfaceProvider);
    // await firestoreInterface.collection('users').doc('test-user').set({
    //   'name': 'Test User',
    //   'email': 'test@example.com',
    // });
  }

  /// Check if we're using mock Firebase
  static bool get isMockEnabled => false;

  /// Add a visual indicator to show we're using mock Firebase
  static Widget addMockIndicator(Widget child) {
    // if (!useMockFirebase) return child;
    return child;

    // return Directionality(
    //   textDirection: TextDirection.ltr,
    //   child: Banner(
    //     message: 'MOCK',
    //     location: BannerLocation.topEnd,
    //     color: Colors.orange,
    //     child: child,
    //   ),
    // );
  }
}
