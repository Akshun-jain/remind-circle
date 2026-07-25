import 'package:flutter/material.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

import 'package:remind_circle/features/events/presentation/screens/create_event_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/events/presentation/providers/group_events_provider.dart';

import 'package:remind_circle/features/events/presentation/widgets/event_card.dart';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:remind_circle/features/groups/presentation/screens/group_members_screen.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(groupEventsProvider(group.id));
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateEventScreen(group: group)),
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
                                '${group.admins.length + 1}',
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                        ClipboardData(text: group.inviteCode),
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Invite code copied'),
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
                loading: () => const Center(child: CircularProgressIndicator()),

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
                          Icon(Icons.event_note, size: 72, color: Colors.grey),

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

                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateEventScreen(
                                group: group,
                                initialEvent: event,
                              ),
                            ),
                          );
                        },
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
  }
}
