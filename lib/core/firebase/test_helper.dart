import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_mock.dart';
import 'firebase_module.dart';

/// A helper class for Firebase testing utilities
class FirebaseTestHelper {
  /// Creates a test container with Firebase mock implementations
  static ProviderContainer createTestContainer() {
    final container = ProviderContainer(
      overrides: [
        // Force mock implementations regardless of the useMockFirebase flag
        authInterfaceProvider.overrideWithValue(FirebaseAuthMock()),
        firestoreInterfaceProvider.overrideWithValue(FirestoreMock()),
        storageInterfaceProvider.overrideWithValue(StorageMock()),
      ],
    );

    // Add disposal of the container after tests
    addTearDown(container.dispose);

    return container;
  }

  /// Creates a test user and signs them in
  static Future<void> authenticateTestUser(
    ProviderContainer container, {
    String email = 'test@example.com',
    String password = 'password123',
    String name = 'Test User',
  }) async {
    final auth = container.read(authInterfaceProvider);

    try {
      // Try to create the user first
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // If user already exists, just sign in
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  /// Creates sample test data in Firestore
  static Future<void> setupTestData(ProviderContainer container) async {
    final firestore = container.read(firestoreInterfaceProvider);

    // Sample user data
    await firestore.doc('users/test-user-id').set({
      'name': 'Test User',
      'email': 'test@example.com',
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Sample product data
    await firestore.collection('products').doc('product-1').set({
      'name': 'Test Product 1',
      'price': 19.99,
      'inStock': true,
    });

    await firestore.collection('products').doc('product-2').set({
      'name': 'Test Product 2',
      'price': 29.99,
      'inStock': false,
    });
  }

  /// Clears all test data
  static Future<void> clearTestData(ProviderContainer container) async {
    final auth = container.read(authInterfaceProvider) as FirebaseAuthMock;
    final firestore =
        container.read(firestoreInterfaceProvider) as FirestoreMock;

    // Sign out any authenticated user
    await auth.signOut();

    // Clear collections (would depend on your mock implementation)
    // This is a simplified example
    await firestore.collection('users').doc('test-user-id').delete();
    await firestore.collection('products').doc('product-1').delete();
    await firestore.collection('products').doc('product-2').delete();
  }
}
