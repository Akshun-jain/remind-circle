import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/features/groups/data/providers/group_repository_provider.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

final groupControllerProvider = AsyncNotifierProvider<GroupController, Group?>(
  GroupController.new,
);

class GroupController extends AsyncNotifier<Group?> {
  @override
  Future<Group?> build() async {
    return null;
  }

  Future<Group> createGroup({
    required String name,
    required String ownerId,
  }) async {
    state = const AsyncLoading();

    final group = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      return repository.createGroup(name: name, ownerId: ownerId);
    });

    state = group;

    return group.requireValue;
  }

  Future<void> joinGroup({
    required String inviteCode,
    required String userId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.joinGroup(
        inviteCode: inviteCode,
        userId: userId,
      );

      return null;
    });
  }
}
