import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/shared/models/user_model.dart';

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
    ref.listen(authStateProvider, (previous, next) {
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
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading;
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.error;
      rethrow;
    }
  }
}
