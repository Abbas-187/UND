import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../providers/firebase_providers.dart';

part 'auth_repository.g.dart';

@riverpod
class AuthRepository extends _$AuthRepository {
  @override
  FutureOr<void> build() {
    // Nothing to return initially
  }

  Stream<User?> authStateChanges() {
    final auth = ref.read(firebaseAuthProvider);
    return auth.authStateChanges();
  }

  Stream<UserModel?> userModelStream() {
    final auth = ref.read(firebaseAuthProvider);
    final firestore = ref.read(firestoreProvider);

    return auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }

      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;

      // Update last login
      await firestore.collection('users').doc(user.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel.fromFirebase(user, claims);
    });
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;

      return UserModel.fromFirebase(user, claims);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();
  }

  Future<String?> getCurrentUserRole() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }

    final idTokenResult = await user.getIdTokenResult(true);
    return idTokenResult.claims?['role'] as String?;
  }

  // Helper to handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'weak-password':
        return Exception(
            'The password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many login attempts. Please try again later.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
