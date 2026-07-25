import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/user/data/providers/user_repository_provider.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

final groupMembersProvider = FutureProvider.family<List<UserProfile>, Group>((
  ref,
  group,
) async {
  final repository = ref.read(userRepositoryProvider);

  final users = await repository.getUsersByIds(group.memberIds);

  return users;
});
