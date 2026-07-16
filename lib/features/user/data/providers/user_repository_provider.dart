import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/user/data/repositories/firestore_user_repository.dart';

final userRepositoryProvider = Provider<FirestoreUserRepository>((ref) {
  return FirestoreUserRepository(FirestoreService());
});
