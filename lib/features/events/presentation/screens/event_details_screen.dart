import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:remind_circle/features/events/domain/models/event.dart';
import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';

import 'package:remind_circle/features/events/presentation/screens/create_event_screen.dart';
import 'package:remind_circle/features/events/presentation/providers/event_controller.dart';

import 'package:remind_circle/features/groups/domain/models/group.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.group,
    required this.canManageEvent,
  });

  final Event event;
  final Group group;
  final bool canManageEvent;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  late Event event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),

            const SizedBox(height: 28),

            _buildInfoCard(context),

            const SizedBox(height: 20),

            if (event.notes != null && event.notes!.trim().isNotEmpty)
              _buildNotesCard(context),

            if (widget.canManageEvent) ...[
              const SizedBox(height: 28),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            child: Text(
              _emoji(event.eventType),
              style: const TextStyle(fontSize: 34),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            event.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          if (event.personName != null &&
              event.personName!.trim().isNotEmpty &&
              event.personName!.trim() != event.title.trim()) ...[
            const SizedBox(height: 6),
            Text(
              event.personName!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],

          const SizedBox(height: 6),

          Text(
            _eventTypeName(event.eventType),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoRow(
              icon: Icons.calendar_month,
              title: 'Date',
              value: DateFormat('EEEE, d MMMM yyyy').format(event.eventDate),
            ),

            const Divider(height: 28),

            _infoRow(
              icon: Icons.groups,
              title: 'Group',
              value: widget.group.name,
            ),

            const Divider(height: 28),

            _infoRow(
              icon: Icons.schedule,
              title: 'Time',
              value: event.eventTime == null
                  ? 'All day · 9:00 AM notification time'
                  : DateFormat('h:mm a').format(event.eventTime!),
            ),

            const Divider(height: 28),

            _infoRow(
              icon: Icons.repeat,
              title: 'Repeats',
              value: _repeatLabel(event.repeatType),
            ),

            const Divider(height: 28),

            _infoRow(
              icon: Icons.notifications,
              title: 'Reminders',
              value: _reminderLabel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 4),

              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes),
                SizedBox(width: 10),
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(event.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final updatedEvent = await Navigator.push<Event>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CreateEventScreen(group: widget.group, initialEvent: event),
              ),
            );

            if (updatedEvent != null && mounted) {
              setState(() {
                event = updatedEvent;
              });
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Event'),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () => _deleteEvent(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Event'),
        ),
      ],
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
            'Are you sure you want to delete this event?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(eventControllerProvider.notifier).deleteEvent(event);

    if (!context.mounted) return;

    final state = ref.read(eventControllerProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: ${state.error}')),
      );
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully.')),
    );
  }

  String _reminderLabel() {
    if (event.notifyBefore.isEmpty) {
      return 'No reminders';
    }

    return event.notifyBefore
        .map((days) {
          if (days == 0) {
            return 'Same day';
          }

          return '$days day${days == 1 ? '' : 's'} before';
        })
        .join(', ');
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
      case EventType.other:
        return '📅';
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
      case EventType.other:
        return 'Other';
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
