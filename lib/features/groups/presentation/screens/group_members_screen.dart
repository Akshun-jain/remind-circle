import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/groups/presentation/providers/group_members_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remind_circle/features/groups/domain/models/group_role.dart';
import 'package:remind_circle/features/groups/presentation/widgets/member_tile.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';
import 'package:remind_circle/features/groups/presentation/providers/group_controller.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(group));

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members found'));
          }

          final currentUid = FirebaseAuth.instance.currentUser?.uid;

          final sortedMembers = [...members];

          sortedMembers.sort((a, b) {
            int priority(UserProfile user) {
              if (group.ownerId == user.uid) return 0;
              if (group.admins.contains(user.uid)) return 1;
              return 2;
            }

            return priority(a).compareTo(priority(b));
          });

          return ListView.builder(
            itemCount: sortedMembers.length,
            itemBuilder: (context, index) {
              final user = sortedMembers[index];

              GroupRole role;

              if (group.ownerId == user.uid) {
                role = GroupRole.owner;
              } else if (group.admins.contains(user.uid)) {
                role = GroupRole.admin;
              } else {
                role = GroupRole.member;
              }

              final isOwnerViewing = group.ownerId == currentUid;
              final isOwnTile = user.uid == currentUid;

              return MemberTile(
                user: user,
                role: role,
                isCurrentUser: isOwnTile,

                trailing: isOwnerViewing && !isOwnTile
                    ? PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'promote':
                              await ref
                                  .read(groupControllerProvider.notifier)
                                  .promoteToAdmin(
                                    groupId: group.id,
                                    userId: user.uid,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${user.name} is now an admin.',
                                    ),
                                  ),
                                );
                              }

                              break;

                            case 'remove':
                              // We'll implement this next.
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'promote',
                            child: Text('Promote to Admin'),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove Member'),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
