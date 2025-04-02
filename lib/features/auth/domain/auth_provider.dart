import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../shared/models/user_model.dart';
import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<UserModel?> currentUser(CurrentUserRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
}

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    ref.listen(currentUserProvider, (previous, next) {
      if (next is AsyncLoading) {
        state = AuthState.loading;
      } else if (next is AsyncError) {
        state = AuthState.error;
      } else if (next is AsyncData) {
        if (next.value != null) {
          state = AuthState.authenticated;
        } else {
          state = AuthState.unauthenticated;
        }
      }
    });

    return AuthState.initial;
  }

  Future<void> signIn(String email, String password) async {
    state = AuthState.loading;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }
}
