import 'package:firebase_auth/firebase_auth.dart';
import 'package:remind_circle/core/services/firebase_auth_service.dart';
import 'package:remind_circle/core/services/google_auth_service.dart';
import 'package:remind_circle/features/auth/data/repositories/auth_repository.dart';
import 'package:remind_circle/features/auth/domain/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseService, this._googleService);

  final FirebaseAuthService _firebaseService;
  final GoogleAuthService _googleService;

  @override
  Future<AppUser> signInWithGoogle() async {
    final credential = await _googleService.signIn();

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
    await _googleService.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final User? user = _firebaseService.currentUser;

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
    return _firebaseService.authStateChanges().map((user) {
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
