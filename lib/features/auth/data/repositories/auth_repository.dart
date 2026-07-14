import 'package:remind_circle/features/auth/domain/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  AppUser? getCurrentUser();

  Stream<AppUser?> authStateChanges();
}
