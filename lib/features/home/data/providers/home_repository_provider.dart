import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/home/data/repositories/firestore_home_repository.dart';

final homeRepositoryProvider = Provider<FirestoreHomeRepository>((ref) {
  return FirestoreHomeRepository(FirestoreService());
});
