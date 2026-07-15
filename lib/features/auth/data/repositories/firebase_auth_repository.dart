import 'package:remind_circle/core/services/firebase_auth_service.dart';
import 'package:remind_circle/core/services/google_auth_service.dart';
import 'package:remind_circle/features/auth/data/repositories/auth_repository.dart';
import 'package:remind_circle/features/auth/domain/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuthService, this._googleAuthService);

  final FirebaseAuthService _firebaseAuthService;
  final GoogleAuthService _googleAuthService;

  @override
  Future<AppUser> signInWithGoogle() async {
    final credential = await _googleAuthService.signIn();

    final user = credential.user!;

    return AppUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleAuthService.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = _firebaseAuthService.currentUser;

    if (user == null) return null;

    return AppUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuthService.authStateChanges().map((user) {
      if (user == null) return null;

      return AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
    });
  }
}
