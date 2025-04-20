import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_interface.dart';
import 'firebase_mock.dart';

part 'firebase_module.g.dart';

/// Toggle this flag to switch between real and mock Firebase
/// Set to true to use mock data on all platforms for testing purposes
const bool useMockFirebase = true;

// Firebase Auth Provider
@riverpod
AuthInterface authInterface(AutoDisposeProviderRef<AuthInterface> ref) {
  if (useMockFirebase) {
    // Use the mock implementation
    return FirebaseAuthMock();
  } else {
    // Use the real implementation
    return FirebaseAuthReal();
  }
}

// Firestore Provider
@riverpod
FirestoreInterface firestoreInterface(
    AutoDisposeProviderRef<FirestoreInterface> ref) {
  if (useMockFirebase) {
    // Use the mock implementation
    return FirestoreMock();
  } else {
    // Use the real implementation
    return FirestoreReal();
  }
}

// Firebase Storage Provider
@riverpod
StorageInterface storageInterface(
    AutoDisposeProviderRef<StorageInterface> ref) {
  if (useMockFirebase) {
    // Use the mock implementation
    return StorageMock();
  } else {
    // Use the real implementation
    return StorageReal();
  }
}
