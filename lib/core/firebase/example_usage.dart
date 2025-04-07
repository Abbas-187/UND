import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_module.dart';
import 'firebase_interface.dart';

part 'example_usage.g.dart';

/// Example provider that uses Firebase auth interface
@riverpod
class AuthExample extends _$AuthExample {
  @override
  FutureOr<void> build() {
    // Nothing to return initially
  }

  Future<bool> login(String email, String password) async {
    try {
      final authInterface = ref.read(authInterfaceProvider);

      // Using the interface which could be either real or mock
      await authInterface.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final authInterface = ref.read(authInterfaceProvider);

      // Using the interface which could be either real or mock
      await authInterface.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Example provider that uses Firestore interface
@riverpod
class FirestoreExample extends _$FirestoreExample {
  @override
  FutureOr<void> build() {
    // Nothing to return initially
  }

  Future<void> saveUserData(
      String userId, Map<String, dynamic> userData) async {
    final firestoreInterface = ref.read(firestoreInterfaceProvider);

    // Using the interface which could be either real or mock
    final userDoc = firestoreInterface.doc('users/$userId');
    await userDoc.set(userData);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final firestoreInterface = ref.read(firestoreInterfaceProvider);

    // Using the interface which could be either real or mock
    final userDoc = firestoreInterface.doc('users/$userId');
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }
}

/// Example provider that uses Storage interface
@riverpod
class StorageExample extends _$StorageExample {
  @override
  FutureOr<void> build() {
    // Nothing to return initially
  }

  Future<String> uploadProfilePicture(
      String userId, Uint8List imageData) async {
    final storageInterface = ref.read(storageInterfaceProvider);

    // Using the interface which could be either real or mock
    final storageRef = storageInterface.ref('users/$userId/profile.jpg');
    await storageRef.putData(imageData);

    // Get download URL
    return await storageRef.getDownloadURL();
  }
}

/// Example UI that shows how to use the providers
class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Mock Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Register a test user
                final success =
                    await ref.read(authExampleProvider.notifier).register(
                          'test@example.com',
                          'password123',
                        );

                if (success) {
                  // Save some user data
                  await ref
                      .read(firestoreExampleProvider.notifier)
                      .saveUserData(
                    'test-user-id',
                    {
                      'name': 'Test User',
                      'email': 'test@example.com',
                      'createdAt': DateTime.now().toIso8601String(),
                    },
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('User registered and data saved!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration failed')),
                  );
                }
              },
              child: const Text('Register Test User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Login the test user
                final success =
                    await ref.read(authExampleProvider.notifier).login(
                          'test@example.com',
                          'password123',
                        );

                if (success) {
                  // Get the user data
                  final userData = await ref
                      .read(firestoreExampleProvider.notifier)
                      .getUserData(
                        'test-user-id',
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Logged in successfully! User name: ${userData?['name'] ?? 'Unknown'}'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login failed')),
                  );
                }
              },
              child: const Text('Login Test User'),
            ),
          ],
        ),
      ),
    );
  }
}
