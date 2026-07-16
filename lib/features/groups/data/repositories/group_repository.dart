import 'package:remind_circle/features/groups/domain/models/group.dart';

abstract class GroupRepository {
  Future<Group> createGroup({required String name, required String ownerId});

  Future<Group?> getGroup(String groupId);

  Future<Group?> getGroupByInviteCode(String inviteCode);

  Future<void> deleteGroup(String groupId);
}
