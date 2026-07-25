import 'package:flutter/material.dart';

import 'package:remind_circle/features/groups/domain/models/group_role.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.user,
    required this.role,
    required this.isCurrentUser,
    this.trailing,
  });

  final UserProfile user;
  final GroupRole role;
  final bool isCurrentUser;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    IconData roleIcon;
    String roleLabel;
    Color roleColor;

    switch (role) {
      case GroupRole.owner:
        roleIcon = Icons.workspace_premium;
        roleLabel = 'Owner';
        roleColor = Colors.orange;
        break;

      case GroupRole.admin:
        roleIcon = Icons.shield;
        roleLabel = 'Admin';
        roleColor = Colors.blue;
        break;

      case GroupRole.member:
        roleIcon = Icons.person;
        roleLabel = 'Member';
        roleColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(user.name.characters.first)
              : null,
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),

        subtitle: Row(
          children: [
            Icon(roleIcon, size: 16, color: roleColor),

            const SizedBox(width: 4),

            Text(roleLabel),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
