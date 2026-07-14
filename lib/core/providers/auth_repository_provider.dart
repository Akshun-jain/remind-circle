import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/services/firebase_auth_service.dart';
import 'package:remind_circle/features/auth/data/repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuthService());
});
