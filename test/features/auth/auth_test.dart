import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:und_app/core/firebase/test_helper.dart';
import 'package:und_app/features/auth/domain/repositories/auth_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    // Create a test container with mock Firebase implementations
    container = FirebaseTestHelper.createTestContainer();
  });

  tearDown(() async {
    // Clean up after each test
    await FirebaseTestHelper.clearTestData(container);
  });

  group('Authentication Tests', () {
    test('should register a new user', () async {
      // Get the auth repository from the container
      final authRepository = container.read(authRepositoryProvider);

      // Register a new user
      final user = await authRepository.register(
          'new@example.com', 'password123', 'New User');

      // Verify the user was created with the right info
      expect(user.email, 'new@example.com');
      expect(user.name, 'New User');
      expect(user.id, isNotEmpty);
    });

    test('should sign in an existing user', () async {
      // Set up a test user
      await FirebaseTestHelper.authenticateTestUser(
        container,
        email: 'existing@example.com',
        password: 'password123',
      );

      // Sign out first to ensure we're testing sign in
      await container.read(authRepositoryProvider).logout();

      // Sign in the user
      final user = await container.read(authRepositoryProvider).login(
            'existing@example.com',
            'password123',
          );

      // Verify the user was authenticated
      expect(user.email, 'existing@example.com');
      expect(user.id, isNotEmpty);
    });

    test('should throw exception for wrong password', () async {
      // Set up a test user
      await FirebaseTestHelper.authenticateTestUser(
        container,
        email: 'test@example.com',
        password: 'correctPassword',
      );

      // Sign out first
      await container.read(authRepositoryProvider).logout();

      // Try to sign in with wrong password
      expect(
        () => container.read(authRepositoryProvider).login(
              'test@example.com',
              'wrongPassword',
            ),
        throwsException,
      );
    });

    test('should get current user after login', () async {
      // Set up and sign in a test user
      await FirebaseTestHelper.authenticateTestUser(container);

      // Get current user
      final currentUser =
          await container.read(authRepositoryProvider).getCurrentUser();

      // Verify we get the logged in user
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'test@example.com');
    });

    test('should return null after logout', () async {
      // Set up and sign in a test user
      await FirebaseTestHelper.authenticateTestUser(container);

      // Logout
      await container.read(authRepositoryProvider).logout();

      // Get current user should be null
      final currentUser =
          await container.read(authRepositoryProvider).getCurrentUser();
      expect(currentUser, isNull);
    });
  });
}
