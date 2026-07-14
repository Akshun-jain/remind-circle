import 'package:remind_circle/core/services/firebase_auth_service.dart';
import 'package:remind_circle/features/auth/data/repositories/auth_repository.dart';
import 'package:remind_circle/features/auth/domain/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._service);

  final FirebaseAuthService _service;

  @override
  Future<AppUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  AppUser? getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    throw UnimplementedError();
  }
}
