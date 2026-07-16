import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/data/repositories/firestore_group_repository.dart';

final groupRepositoryProvider = Provider<FirestoreGroupRepository>((ref) {
  return FirestoreGroupRepository(FirestoreService());
});
