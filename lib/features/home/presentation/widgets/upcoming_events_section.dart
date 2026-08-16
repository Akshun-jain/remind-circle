import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';

import 'package:remind_circle/features/home/presentation/providers/upcoming_events_provider.dart';
import 'package:remind_circle/features/events/presentation/screens/event_details_screen.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/home/presentation/providers/my_groups_provider.dart';

class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final groups = ref.watch(myGroupsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        upcomingEvents.when(
          data: (events) {
            if (events.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No upcoming events')),
                ),
              );
            }

            return groups.when(
              data: (groupList) {
                return Column(
                  children: events.map((event) {
                    final nextOccurrence = RecurrenceService.getNextOccurrence(
                      event,
                    );

                    if (nextOccurrence == null) {
                      return const SizedBox.shrink();
                    }

                    Group? matchedGroup;

                    for (final candidate in groupList) {
                      if (candidate.id == event.groupId) {
                        matchedGroup = candidate;
                        break;
                      }
                    }

                    if (matchedGroup == null) {
                      return const SizedBox.shrink();
                    }

                    final group = matchedGroup;

                    final userId = currentUser?.uid;

                    final canManageEvent =
                        userId != null &&
                        (event.createdBy == userId ||
                            group.ownerId == userId ||
                            group.admins.contains(userId));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(
                                event: event,
                                group: group,
                                canManageEvent: canManageEvent,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                child: Icon(
                                  _iconForEvent(event.eventType.name),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),

                                    if (event.personName != null &&
                                        event.personName!.trim().isNotEmpty &&
                                        event.personName!.trim() !=
                                            event.title.trim()) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        event.personName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],

                                    if (group.name.trim().isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        group.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('d MMM').format(nextOccurrence),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    _relativeDate(nextOccurrence),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },

              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(e.toString()),
                ),
              ),
            );
          },

          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

          error: (e, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(e.toString()),
            ),
          ),
        ),
      ],
    );
  }

  static IconData _iconForEvent(String type) {
    switch (type.toLowerCase()) {
      case 'birthday':
        return Icons.cake;

      case 'anniversary':
        return Icons.favorite;

      case 'meeting':
        return Icons.business_center;

      case 'festival':
        return Icons.celebration;

      case 'holiday':
        return Icons.beach_access;

      case 'workanniversary':
        return Icons.workspace_premium;

      default:
        return Icons.event;
    }
  }

  static String _relativeDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Tomorrow';
    }

    return 'In $difference days';
  }
}
