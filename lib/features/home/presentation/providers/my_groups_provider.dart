import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/home/data/providers/home_repository_provider.dart';

final myGroupsProvider = StreamProvider<List<Group>>((ref) {
  final authState = ref.watch(authStateProvider);

  final user = authState.value;

  if (user == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(homeRepositoryProvider);

  return repository.myGroups(user.uid);
});
