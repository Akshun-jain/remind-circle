import 'package:flutter/material.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

import 'package:remind_circle/features/events/presentation/screens/create_event_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/events/presentation/providers/group_events_provider.dart';

import 'package:remind_circle/features/events/presentation/widgets/event_card.dart';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:remind_circle/features/groups/presentation/screens/group_members_screen.dart';
import 'package:remind_circle/features/groups/presentation/providers/group_controller.dart';

import 'package:remind_circle/features/events/presentation/providers/event_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({super.key, required this.group});

  final Group group;

  Future<void> _deleteGroup(
    BuildContext context,
    WidgetRef ref,
    String groupId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group?'),
          content: const Text(
            'This will permanently delete the group and all of its events.\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete Group'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final controller = ref.read(groupControllerProvider.notifier);

    await controller.deleteGroup(groupId);

    if (!context.mounted) return;

    final state = ref.read(groupControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete group: ${state.error}')),
      );
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group deleted successfully.')),
    );
  }

  Future<void> _leaveGroup(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Group?'),
          content: const Text(
            'You will lose access to this group and its events.\n\n'
            'You can join again later using the invite code.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave Group'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final controller = ref.read(groupControllerProvider.notifier);

    await controller.leaveGroup(groupId: groupId, userId: userId);

    if (!context.mounted) return;

    final state = ref.read(groupControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave group: ${state.error}')),
      );
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('You left the group.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveGroupAsync = ref.watch(groupProvider(group.id));
    return liveGroupAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text(error.toString()))),

      data: (liveGroup) {
        if (liveGroup == null) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }

        final group = liveGroup;
        final eventsAsync = ref.watch(groupEventsProvider(group.id));

        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final isOwner = group.ownerId == currentUid;

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete' && isOwner) {
                    await _deleteGroup(context, ref, group.id);
                    return;
                  }

                  if (value == 'leave' && !isOwner) {
                    await _leaveGroup(context, ref, group.id, currentUid!);
                  }
                },
                itemBuilder: (context) => [
                  if (isOwner)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 12),
                          Text('Delete Group'),
                        ],
                      ),
                    ),

                  if (!isOwner)
                    const PopupMenuItem<String>(
                      value: 'leave',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(width: 12),
                          Text('Leave Group'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEventScreen(group: group),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),

          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          GroupMembersScreen(group: group),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    const Icon(Icons.people),

                                    const SizedBox(height: 6),

                                    Text(
                                      '${group.memberIds.length}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const Text('Members'),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 55,
                              color: Colors.grey.shade300,
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(Icons.admin_panel_settings),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${group.admins.length}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Admins'),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.key),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Invite Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    group.inviteCode,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.copy),
                                        label: const Text('Copy'),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: group.inviteCode,
                                            ),
                                          );

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Invite code copied',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),

                                      const SizedBox(width: 12),

                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.share),
                                        label: const Text('Share'),
                                        onPressed: () {
                                          Share.share(
                                            'Join my RemindCircle group!\n\n'
                                            'Invite Code: ${group.inviteCode}',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Events',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: eventsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, stackTrace) {
                      debugPrint('EVENT STREAM ERROR: $error');
                      debugPrint(stackTrace.toString());

                      return Center(child: Text(error.toString()));
                    },

                    data: (events) {
                      if (events.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 72,
                                color: Colors.grey,
                              ),

                              SizedBox(height: 16),

                              Text(
                                'No events yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                'Tap + to create your first event.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          final canManageEvent =
                              event.createdBy == currentUid ||
                              group.ownerId == currentUid ||
                              group.admins.contains(currentUid);

                          return EventCard(
                            event: event,
                            onTap: canManageEvent
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateEventScreen(
                                          group: group,
                                          initialEvent: event,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            onMenuSelected: canManageEvent
                                ? (action) async {
                                    switch (action) {
                                      case 'edit':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CreateEventScreen(
                                              group: group,
                                              initialEvent: event,
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'delete':
                                        final shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Delete Event'),
                                              content: const Text(
                                                'Are you sure you want to delete this event?\n\nThis action cannot be undone.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (shouldDelete == true) {
                                          await ref
                                              .read(
                                                eventControllerProvider
                                                    .notifier,
                                              )
                                              .deleteEvent(event);

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Event deleted successfully.',
                                                ),
                                              ),
                                            );
                                          }
                                        }

                                        break;
                                    }
                                  }
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
