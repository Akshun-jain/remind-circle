import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/providers/group_repository_provider.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/core/providers/auth_provider.dart';

final groupProvider = StreamProvider.family<Group?, String>((ref, groupId) {
  final authState = ref.watch(authStateProvider);

  // Do not attach Firestore listeners while signed out.
  if (authState.value == null) {
    return const Stream.empty();
  }

  final repository = ref.read(groupRepositoryProvider);

  return repository.watchGroup(groupId);
});

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

      await repository.joinGroup(inviteCode: inviteCode, userId: userId);

      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> promoteToAdmin({
    required String groupId,
    required String userId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.promoteToAdmin(groupId: groupId, userId: userId);

      return null;
    });
  }

  Future<void> demoteAdmin({
    required String groupId,
    required String userId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.demoteAdmin(groupId: groupId, userId: userId);

      return null;
    });
  }

  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.removeMember(groupId: groupId, userId: userId);

      return null;
    });
  }

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.leaveGroup(groupId: groupId, userId: userId);

      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.deleteGroup(groupId);

      return null;
    });
  }
}
