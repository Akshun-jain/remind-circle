import 'package:remind_circle/features/groups/domain/models/group_role.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

class GroupMember {
  const GroupMember({
    required this.user,
    required this.role,
  });

  final UserProfile user;
  final GroupRole role;
}
