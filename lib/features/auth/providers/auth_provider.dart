import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/features/auth/domain/models/app_user.dart';
import 'package:remind_circle/features/auth/domain/models/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  void setLoading() {
    state = const AuthState.loading();
  }

  void setAuthenticated(AppUser user) {
    state = AuthState.authenticated(user);
  }

  void setUnauthenticated() {
    state = const AuthState.unauthenticated();
  }

  void setError(String message) {
    state = AuthState.error(message);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
