import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_interface.dart';

part 'firebase_providers.g.dart';

// Firebase Auth Provider
@riverpod
AuthInterface firebaseAuth() {
  // Directly using real implementation
  return FirebaseAuthReal();
}

// Firestore Provider
@riverpod
FirestoreInterface firestore() {
  // Directly using real implementation
  return FirestoreReal();
}

// Firebase Storage Provider
@riverpod
StorageInterface storage() {
  // Directly using real implementation
  return StorageReal();
}
