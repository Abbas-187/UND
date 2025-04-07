# Firebase Mock Implementation Example

This document provides simple examples of how to use the mock Firebase implementation.

## 1. Setup

First, ensure the mock implementation is enabled:

```dart
// In lib/core/firebase/firebase_module.dart
const bool useMockFirebase = true; // Set to true for mock, false for real Firebase
```

## 2. Using Authentication

```dart
// Import the interface and module
import 'package:und_app/core/firebase/firebase_interface.dart';
import 'package:und_app/core/firebase/firebase_module.dart';

// Get the auth interface (could be real or mock based on useMockFirebase flag)
final authInterface = ref.read(authInterfaceProvider);

// Register a new user
try {
  final credential = await authInterface.createUserWithEmailAndPassword(
    email: 'test@example.com',
    password: 'password123',
  );
  print('User registered: ${credential.user?.uid}');
} catch (e) {
  print('Registration error: $e');
}

// Sign in
try {
  final credential = await authInterface.signInWithEmailAndPassword(
    email: 'test@example.com',
    password: 'password123',
  );
  print('User signed in: ${credential.user?.uid}');
} catch (e) {
  print('Login error: $e');
}

// Get current user
final user = authInterface.currentUser;
if (user != null) {
  print('Current user: ${user.uid}');
}

// Sign out
await authInterface.signOut();
```

## 3. Using Firestore

```dart
// Import the interface and module
import 'package:und_app/core/firebase/firebase_interface.dart';
import 'package:und_app/core/firebase/firebase_module.dart';

// Get the firestore interface
final firestoreInterface = ref.read(firestoreInterfaceProvider);

// Create a document
final userDoc = firestoreInterface.doc('users/user123');
await userDoc.set({
  'name': 'Test User',
  'email': 'test@example.com',
  'createdAt': DateTime.now().toIso8601String(),
});

// Read a document
final snapshot = await userDoc.get();
if (snapshot.exists) {
  final data = snapshot.data();
  print('User data: $data');
}

// Update a document
await userDoc.update({'lastLogin': DateTime.now().toIso8601String()});

// Query a collection
final usersCollection = firestoreInterface.collection('users');
final usersSnapshot = await usersCollection.get();
print('Number of users: ${usersSnapshot.size}');
```

## 4. Using Storage

```dart
// Import the interface and module
import 'dart:typed_data';
import 'package:und_app/core/firebase/firebase_interface.dart';
import 'package:und_app/core/firebase/firebase_module.dart';

// Get the storage interface
final storageInterface = ref.read(storageInterfaceProvider);

// Upload a file
final imageRef = storageInterface.ref('users/user123/profile.jpg');
final bytes = Uint8List.fromList([/* image data */]);
await imageRef.putData(bytes);

// Get download URL
final downloadUrl = await imageRef.getDownloadURL();
print('Download URL: $downloadUrl');
```

## 5. Testing the Mock Implementation

The mock implementation stores data in memory, so it's perfect for testing. You can:

1. Create test users with any email/password
2. Store and retrieve mock data
3. Upload and download mock files

Since no actual Firebase resources are used, you can develop and test your app without worrying about:
- Firebase project configuration
- Internet connectivity
- Firebase quotas/billing

## 6. Switching Back to Real Firebase

When you're ready to use the real Firebase:

```dart
// In lib/core/firebase/firebase_module.dart
const bool useMockFirebase = false;
```

No other code changes are needed as long as you're using the interfaces consistently throughout your app. 