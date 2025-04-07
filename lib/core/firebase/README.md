# Firebase Mock Implementation

This module provides a mock implementation of Firebase services that can be used for testing and development without requiring a real Firebase backend.

## How to Use

### Toggle between Real and Mock Firebase

1. Open `lib/core/firebase/firebase_module.dart`
2. Set the `useMockFirebase` constant to:
   - `true` to use mock Firebase
   - `false` to use real Firebase

```dart
/// Toggle this flag to switch between real and mock Firebase
const bool useMockFirebase = true; // Change to false for real Firebase
```

### Mock Authentication

The mock authentication allows you to:
- Register new users
- Login with email/password
- Get the current user
- Listen to auth state changes
- Sign out
- Reset passwords

#### Testing Authentication

For testing, you can register a new user with any email/password. The mock implementation will store registered users in memory (not persistent).

Example of registering and logging in:

```dart
await ref.read(authRepositoryProvider).register(
  'test@example.com',
  'password123',
  'Test User'
);

// Later, login with the same credentials
final user = await ref.read(authRepositoryProvider).login(
  'test@example.com',
  'password123'
);
```

### Mock Firestore

The mock Firestore implementation simulates:
- Creating, reading, updating, and deleting documents
- Querying collections
- Running transactions
- Using batch operations

All data is stored in memory and is not persistent between app restarts.

### Mock Storage

The mock Storage implementation provides:
- Uploading files (simulated)
- Downloading files (returns mock URLs)
- Listing files

## Implementation Details

The mock implementations follow the same interfaces as the real Firebase, allowing your code to work with either implementation without changes.

### Architecture

1. **Interfaces**: `lib/core/firebase/firebase_interface.dart` defines the abstract interfaces for Firebase services.

2. **Real Implementations**: Classes like `FirebaseAuthReal`, `FirestoreReal`, and `StorageReal` wrap the actual Firebase SDKs.

3. **Mock Implementations**: Classes like `FirebaseAuthMock`, `FirestoreMock`, and `StorageMock` provide in-memory implementations.

4. **Provider Module**: `lib/core/firebase/firebase_module.dart` provides Riverpod providers that return either the real or mock implementation based on the `useMockFirebase` flag.

## Adding New Firebase Features

When adding new Firebase functionality:

1. Add the method to the relevant interface in `firebase_interface.dart`
2. Implement the method in both the real and mock classes
3. Use the interface in your repositories and data sources

This ensures your code can easily switch between real and mock implementations.

## Limitations

The mock implementation has some limitations:
- Data is not persistent between app restarts
- Complex queries may not behave exactly like the real Firebase
- Some Firebase-specific features like security rules are not implemented
- Real-time updates are simulated and may not match Firebase's behavior exactly 