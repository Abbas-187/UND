import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/permission.dart';
import '../models/user_role.dart';

/// Provider for the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

/// Provider for the current user
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider to check if the current user has a specific permission
final hasPermissionProvider =
    Provider.family<bool, Permission>((ref, permission) {
  final userAsyncValue = ref.watch(currentUserProvider);
  return userAsyncValue.when(
    data: (user) => user?.hasPermission(permission) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Service for handling authentication related functionality
class AuthService {

  AuthService(this._firebaseAuth, this._firestore);
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Collection reference for users
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Stream of auth state changes mapped to AppUser
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap(_userFromFirebase);
  }

  /// Current user getter
  AppUser? get currentUser => _firebaseAuth.currentUser != null
      ? AppUser(
          id: _firebaseAuth.currentUser!.uid,
          email: _firebaseAuth.currentUser!.email!,
          displayName: _firebaseAuth.currentUser!.displayName ??
              _firebaseAuth.currentUser!.email!.split('@').first,
          role: UserRole.viewer, // Default role, will be updated from Firestore
          emailVerified: _firebaseAuth.currentUser!.emailVerified,
          photoUrl: _firebaseAuth.currentUser!.photoURL,
          createdAt: DateTime.now(),
        )
      : null;

  /// Sign in with email and password
  Future<AppUser> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed: No user returned from Firebase');
      }

      // Update last login timestamp
      await _usersCollection.doc(user.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      // Get user with full details
      final appUser = await _userFromFirebase(user);
      if (appUser == null) {
        throw Exception('Failed to get user data from Firestore');
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<AppUser> signUpWithEmailAndPassword(
      String email, String password, String displayName,
      {UserRole role = UserRole.viewer}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign up failed: No user returned from Firebase');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user document in Firestore
      final userData = {
        'id': user.uid,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'emailVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };

      await _usersCollection.doc(user.uid).set(userData);

      // Get user with full details
      final appUser = await _userFromFirebase(user);
      if (appUser == null) {
        throw Exception('Failed to get user data from Firestore');
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update a user's role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _usersCollection.doc(userId).update({
        'role': newRole.name,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Get all users (admin only)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();

      return Future.wait(
        querySnapshot.docs.map((doc) async {
          final userData = doc.data();

          // If we can't get the auth user, just use the Firestore data
          return AppUser(
            id: doc.id,
            email: userData['email'] as String,
            displayName: userData['displayName'] as String,
            role: _parseRoleFromString(userData['role'] as String?),
            emailVerified: userData['emailVerified'] as bool? ?? false,
            photoUrl: userData['photoUrl'] as String?,
            createdAt: DateTime.parse(userData['createdAt'] as String),
            lastLoginAt: userData['lastLoginAt'] != null
                ? DateTime.parse(userData['lastLoginAt'] as String)
                : null,
          );
        }).toList(),
      );
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Parse role from string
  UserRole _parseRoleFromString(String? roleStr) {
    if (roleStr == null) return UserRole.viewer;

    try {
      return UserRole.values.firstWhere(
        (role) => role.name == roleStr,
        orElse: () => UserRole.viewer,
      );
    } catch (_) {
      return UserRole.viewer;
    }
  }

  /// Delete a user (admin only)
  Future<void> deleteUser(String userId) async {
    try {
      // Delete from Firestore first
      await _usersCollection.doc(userId).delete();

      // For Firebase Auth deletion, this might need admin SDK
      // This won't work in client-side Flutter app directly
      // Consider using a Cloud Function to handle this part
      // For now, we'll just focus on deleting from Firestore
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Map Firebase User to AppUser
  Future<AppUser?> _userFromFirebase(User? user) async {
    if (user == null) return null;

    try {
      // Get additional user data from Firestore
      final doc = await _usersCollection.doc(user.uid).get();
      final firestoreData = doc.exists ? doc.data() : null;

      // Get user's ID token result to access custom claims
      final idTokenResult = await user.getIdTokenResult();
      final authData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'emailVerified': user.emailVerified,
        'photoURL': user.photoURL,
        'claims': idTokenResult.claims ?? {},
      };

      if (firestoreData != null) {
        // Use a combination of auth data and firestore data
        return AppUser(
          id: user.uid,
          email: user.email ?? firestoreData['email'] as String,
          displayName:
              user.displayName ?? firestoreData['displayName'] as String,
          role: _parseRoleFromString(firestoreData['role'] as String?),
          emailVerified: user.emailVerified,
          photoUrl: user.photoURL,
          createdAt: firestoreData['createdAt'] != null
              ? DateTime.parse(firestoreData['createdAt'] as String)
              : DateTime.now(),
          lastLoginAt: firestoreData['lastLoginAt'] != null
              ? DateTime.parse(firestoreData['lastLoginAt'] as String)
              : null,
          customClaims: idTokenResult.claims ?? {},
        );
      } else {
        // If no Firestore data, return basic user info
        return AppUser(
          id: user.uid,
          email: user.email ?? '',
          displayName:
              user.displayName ?? user.email?.split('@').first ?? 'User',
          role: UserRole.viewer, // Default role
          emailVerified: user.emailVerified,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          customClaims: idTokenResult.claims ?? {},
        );
      }
    } catch (e) {
      // If we can't get Firestore data, return basic user info
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
        role: UserRole.viewer, // Default role
        emailVerified: user.emailVerified,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Handle Firebase Auth exceptions with user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('This email is already registered');
      case 'weak-password':
        return Exception('The password is too weak');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This user account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
