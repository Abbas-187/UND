import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_interface.dart';
import 'firebase_mock.dart';

part 'firebase_providers.g.dart';

/// Toggle this flag to switch between real and mock Firebase
const bool useMockFirebase = true;

// Firebase Auth Provider
@riverpod
AuthInterface firebaseAuth(FirebaseAuthRef ref) {
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
FirestoreInterface firestore(FirestoreRef ref) {
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
StorageInterface storage(StorageRef ref) {
  if (useMockFirebase) {
    // Use the mock implementation
    return StorageMock();
  } else {
    // Use the real implementation
    return StorageReal();
  }
}
