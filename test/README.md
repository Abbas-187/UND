# Testing Guide for Firebase Mock Implementation

This guide explains how to test your app using the mock Firebase implementation.

## Setup

1. **Enable Mock Implementation**

   In `lib/core/firebase/firebase_module.dart`, ensure the `useMockFirebase` flag is set to `true`:

   ```dart
   const bool useMockFirebase = true;
   ```

2. **Run Code Generation**

   Generate the necessary Riverpod code:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Install Test Dependencies**

   Ensure these dependencies are in your `pubspec.yaml`:

   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     mockito: ^5.4.5
   ```

## Running Tests

Run all tests with:

```bash
flutter test
```

Or run specific tests:

```bash
flutter test test/features/auth/auth_test.dart
```

## Testing Structure

### Test Helper

The `lib/core/firebase/test_helper.dart` file provides utilities for testing:

- `createTestContainer()`: Creates a container with mock Firebase implementations
- `authenticateTestUser()`: Creates and signs in a test user
- `setupTestData()`: Sets up sample test data in Firestore
- `clearTestData()`: Cleans up test data

### Test Examples

1. **Authentication Tests** (`test/features/auth/auth_test.dart`)
   - Register user
   - Login user
   - Get current user
   - Logout

2. **Firestore Tests** (`test/features/firestore/firestore_test.dart`)
   - Read documents
   - Update documents
   - Query collections
   - Delete documents

## Writing Your Own Tests

1. **Create a Test File**:

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:und_app/core/firebase/test_helper.dart';

   void main() {
     late ProviderContainer container;

     setUp(() {
       container = FirebaseTestHelper.createTestContainer();
     });

     tearDown(() async {
       await FirebaseTestHelper.clearTestData(container);
     });

     group('Your Test Group', () {
       test('Your test case', () async {
         // Test code here
       });
     });
   }
   ```

2. **Access Mock Firebase**:

   ```dart
   // Get interfaces
   final auth = container.read(authInterfaceProvider);
   final firestore = container.read(firestoreInterfaceProvider);
   final storage = container.read(storageInterfaceProvider);
   
   // Or get your repositories directly
   final authRepo = container.read(authRepositoryProvider);
   ```

3. **Prepare Test Data**:

   ```dart
   // Set up data before test
   await FirebaseTestHelper.setupTestData(container);
   
   // Or create custom data
   await firestore.doc('custom/document').set({
     'field': 'value',
   });
   ```

4. **Test Your Features**:

   ```dart
   // Test your feature
   final result = await yourFeature.doSomething();
   
   // Make assertions
   expect(result, expectedValue);
   ```

## Mock Implementation Limitations

- Data is stored in memory and not persisted between tests
- Complex queries may not exactly match Firebase behavior
- Some Firebase-specific features are simplified
- Real-time updates are simulated

## Integration vs Unit Tests

- **Unit Tests**: Test individual components using the mock interfaces
- **Widget Tests**: Test UI components with mock data
- **Integration Tests**: Test multiple components working together

## Debugging Tests

If your tests are failing, you can:

1. Add print statements in your tests
2. Examine the state of your mock data
3. Step through tests using your IDE's debugger
4. Use `FirebaseTestHelper` methods to verify data setup 