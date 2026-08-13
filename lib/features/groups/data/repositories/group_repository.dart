import 'package:remind_circle/features/groups/domain/models/group.dart';

abstract class GroupRepository {
  Future<Group> createGroup({required String name, required String ownerId});

  Future<Group?> getGroup(String groupId);

  Stream<Group?> watchGroup(String groupId);

  Future<Group?> getGroupByInviteCode(String inviteCode);

  Future<void> deleteGroup(String groupId);

  Future<void> joinGroup({required String inviteCode, required String userId});

  Future<void> promoteToAdmin({
    required String groupId,
    required String userId,
  });

  Future<void> demoteAdmin({required String groupId, required String userId});

  Future<void> removeMember({required String groupId, required String userId});

  Future<void> leaveGroup({required String groupId, required String userId});
}
