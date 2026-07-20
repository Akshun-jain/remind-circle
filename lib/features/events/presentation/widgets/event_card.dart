import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, this.onTap, required this.event});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
              children: [
                CircleAvatar(
                  child: Text(
                    _emoji(event.eventType),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _eventTypeName(event.eventType),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(event.title, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),

                const SizedBox(width: 8),

                Text(DateFormat('EEEE, d MMMM yyyy').format(event.eventDate)),
              ],
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.repeat, size: 18),
                  label: Text(_repeatLabel(event.repeatType)),
                ),

                ...event.notifyBefore.map(
                  (days) => Chip(
                    avatar: const Icon(Icons.notifications, size: 18),
                    label: Text(
                      days == 0
                          ? 'Same Day'
                          : '$days Day${days > 1 ? 's' : ''}',
                    ),
                  ),
                ),
              ],
            ),

            if (event.notes != null && event.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),

              Text(event.notes!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
      ),
    );
  }

  String _emoji(EventType type) {
    switch (type) {
      case EventType.birthday:
        return '🎂';

      case EventType.anniversary:
        return '💍';

      case EventType.workAnniversary:
        return '🏆';

      case EventType.meeting:
        return '📅';

      case EventType.festival:
        return '🎉';

      case EventType.holiday:
        return '🏖️';

      case EventType.custom:
        return '📌';
    }
  }

  String _eventTypeName(EventType type) {
    switch (type) {
      case EventType.birthday:
        return 'Birthday';

      case EventType.anniversary:
        return 'Anniversary';

      case EventType.workAnniversary:
        return 'Work Anniversary';

      case EventType.meeting:
        return 'Meeting';

      case EventType.festival:
        return 'Festival';

      case EventType.holiday:
        return 'Holiday';

      case EventType.custom:
        return 'Custom';
    }
  }

  String _repeatLabel(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.none:
        return 'Does not repeat';

      case RepeatType.monthly:
        return 'Every Month';

      case RepeatType.yearly:
        return 'Every Year';
    }
  }
}
