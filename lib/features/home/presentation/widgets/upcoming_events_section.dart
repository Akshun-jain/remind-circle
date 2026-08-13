import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/home/presentation/providers/upcoming_events_provider.dart';

import 'package:remind_circle/core/utils/date_formatter_helper.dart';
import 'package:remind_circle/core/utils/next_occurrence_helper.dart';

class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcomingEventsProvider);

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

            return Column(
              children: events.map((event) {
                final nextOccurrence = NextOccurrenceHelper.getNextOccurrence(
                  eventDate: event.eventDate,
                  repeatType: event.repeatType,
                );

                final formattedDate = DateFormatterHelper.formatRelative(
                  nextOccurrence,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      child: Icon(_iconForEvent(event.eventType.name)),
                    ),
                    title: Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (event.personName != null)
                            Text(
                              event.personName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          const SizedBox(height: 4),

                          Text(
                            event.repeatType.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ],
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

      default:
        return Icons.event;
    }
  }
}
