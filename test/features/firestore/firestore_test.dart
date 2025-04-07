import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/core/firebase/firebase_interface.dart';
import 'package:und_app/core/firebase/firebase_module.dart';
import 'package:und_app/core/firebase/test_helper.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    // Create a test container with mock Firebase implementations
    container = FirebaseTestHelper.createTestContainer();

    // Set up test data
    return FirebaseTestHelper.setupTestData(container);
  });

  tearDown(() async {
    // Clean up after each test
    await FirebaseTestHelper.clearTestData(container);
  });

  group('Firestore Tests', () {
    test('should read user data', () async {
      // Get the firestore interface
      final firestore = container.read(firestoreInterfaceProvider);

      // Read the test user document
      final snapshot = await firestore.doc('users/test-user-id').get();

      // Verify document exists and has correct data
      expect(snapshot.exists, isTrue);
      final data = snapshot.data() as Map<String, dynamic>;
      expect(data['name'], 'Test User');
      expect(data['email'], 'test@example.com');
      expect(data['role'], 'user');
    });

    test('should update user data', () async {
      // Get the firestore interface
      final firestore = container.read(firestoreInterfaceProvider);

      // Update the test user document
      await firestore.doc('users/test-user-id').update({
        'role': 'admin',
        'lastLogin': DateTime.now().toIso8601String(),
      });

      // Read the updated document
      final snapshot = await firestore.doc('users/test-user-id').get();
      final data = snapshot.data() as Map<String, dynamic>;

      // Verify the update was applied
      expect(data['role'], 'admin');
      expect(data['lastLogin'], isNotNull);

      // Original data should still be there
      expect(data['name'], 'Test User');
      expect(data['email'], 'test@example.com');
    });

    test('should query collection', () async {
      // Get the firestore interface
      final firestore = container.read(firestoreInterfaceProvider);

      // Query the products collection
      final snapshot = await firestore.collection('products').get();

      // Verify we get the correct number of products
      expect(snapshot.size, 2);

      // Verify documents have correct data
      final docs = snapshot.docs;

      // Sort products by name for consistent testing
      final sortedDocs = List.from(docs)
        ..sort((a, b) =>
            (a.data() as Map)['name'].compareTo((b.data() as Map)['name']));

      expect((sortedDocs[0].data() as Map)['name'], 'Test Product 1');
      expect((sortedDocs[0].data() as Map)['price'], 19.99);
      expect((sortedDocs[0].data() as Map)['inStock'], isTrue);

      expect((sortedDocs[1].data() as Map)['name'], 'Test Product 2');
      expect((sortedDocs[1].data() as Map)['price'], 29.99);
      expect((sortedDocs[1].data() as Map)['inStock'], isFalse);
    });

    test('should delete document', () async {
      // Get the firestore interface
      final firestore = container.read(firestoreInterfaceProvider);

      // Delete a product
      await firestore.doc('products/product-1').delete();

      // Try to read the deleted document
      final snapshot = await firestore.doc('products/product-1').get();

      // Verify document no longer exists
      expect(snapshot.exists, isFalse);

      // Other documents should still exist
      final snapshot2 = await firestore.doc('products/product-2').get();
      expect(snapshot2.exists, isTrue);
    });
  });
}
