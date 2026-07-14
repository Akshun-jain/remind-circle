import 'package:remind_circle/features/auth/domain/models/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      errorMessage = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      errorMessage = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      errorMessage = null;

  const AuthState.authenticated(this.user)
    : status = AuthStatus.authenticated,
      errorMessage = null;

  const AuthState.error(this.errorMessage)
    : status = AuthStatus.error,
      user = null;
}
