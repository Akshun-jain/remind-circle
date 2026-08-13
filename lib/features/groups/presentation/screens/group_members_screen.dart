import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/groups/domain/models/group_role.dart';
import 'package:remind_circle/features/groups/presentation/providers/group_members_controller.dart';
import 'package:remind_circle/features/groups/presentation/providers/group_controller.dart';
import 'package:remind_circle/features/groups/presentation/widgets/member_tile.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key, required this.group});

  final Group group;

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IMPORTANT:
    // Listen to the live Firestore group document so changes to
    // admins/memberIds are reflected immediately.
    final liveGroupAsync = ref.watch(groupProvider(group.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: liveGroupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (liveGroup) {
          if (liveGroup == null) {
            return const Center(child: Text('Group no longer exists'));
          }

          // Use the LIVE group here, not the stale group passed
          // into this screen.
          final membersAsync = ref.watch(groupMembersProvider(liveGroup));

          return membersAsync.when(
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
                  if (liveGroup.ownerId == user.uid) {
                    return 0;
                  }

                  if (liveGroup.admins.contains(user.uid)) {
                    return 1;
                  }

                  return 2;
                }

                return priority(a).compareTo(priority(b));
              });

              return ListView.builder(
                itemCount: sortedMembers.length,
                itemBuilder: (context, index) {
                  final user = sortedMembers[index];

                  GroupRole role;

                  if (liveGroup.ownerId == user.uid) {
                    role = GroupRole.owner;
                  } else if (liveGroup.admins.contains(user.uid)) {
                    role = GroupRole.admin;
                  } else {
                    role = GroupRole.member;
                  }

                  final isOwnerViewing = liveGroup.ownerId == currentUid;

                  final isOwnTile = user.uid == currentUid;

                  return MemberTile(
                    user: user,
                    role: role,
                    isCurrentUser: isOwnTile,
                    trailing:
                        isOwnerViewing && role != GroupRole.owner && !isOwnTile
                        ? PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'promote':
                                  final confirmed = await _confirmAction(
                                    context,
                                    title: 'Promote to Admin?',
                                    message:
                                        '${user.name} will become an admin of this group.',
                                    confirmText: 'Promote',
                                  );

                                  if (!confirmed) return;

                                  await ref
                                      .read(groupControllerProvider.notifier)
                                      .promoteToAdmin(
                                        groupId: liveGroup.id,
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
                                  final confirmed = await _confirmAction(
                                    context,
                                    title: 'Remove Member?',
                                    message:
                                        '${user.name} will be removed from this group and will lose access to its events.',
                                    confirmText: 'Remove',
                                  );

                                  if (!confirmed) return;

                                  await ref
                                      .read(groupControllerProvider.notifier)
                                      .removeMember(
                                        groupId: liveGroup.id,
                                        userId: user.uid,
                                      );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${user.name} removed from the group.',
                                        ),
                                      ),
                                    );
                                  }

                                  break;

                                case 'demote':
                                  final confirmed = await _confirmAction(
                                    context,
                                    title: 'Remove Admin Role?',
                                    message:
                                        '${user.name} will no longer be an admin.',
                                    confirmText: 'Remove Admin',
                                  );

                                  if (!confirmed) return;

                                  await ref
                                      .read(groupControllerProvider.notifier)
                                      .demoteAdmin(
                                        groupId: liveGroup.id,
                                        userId: user.uid,
                                      );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${user.name} is no longer an admin.',
                                        ),
                                      ),
                                    );
                                  }

                                  break;
                              }
                            },
                            itemBuilder: (context) {
                              final items = <PopupMenuEntry<String>>[];

                              if (role == GroupRole.member) {
                                items.add(
                                  const PopupMenuItem(
                                    value: 'promote',
                                    child: Text('Promote to Admin'),
                                  ),
                                );
                              }

                              if (role == GroupRole.admin) {
                                items.add(
                                  const PopupMenuItem(
                                    value: 'demote',
                                    child: Text('Remove Admin'),
                                  ),
                                );
                              }

                              items.add(
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove Member'),
                                ),
                              );

                              return items;
                            },
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
