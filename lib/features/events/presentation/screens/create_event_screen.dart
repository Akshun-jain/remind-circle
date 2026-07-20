import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';

import 'package:remind_circle/features/events/domain/models/event.dart';
import 'package:remind_circle/features/events/presentation/providers/event_controller.dart';
import 'package:remind_circle/features/events/presentation/widgets/event_form.dart';

import 'package:remind_circle/features/groups/domain/models/group.dart';

import 'package:remind_circle/features/events/domain/enums/event_type.dart';

class CreateEventScreen extends ConsumerWidget {
  final Event? initialEvent;

  const CreateEventScreen({super.key, required this.group, this.initialEvent});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;

    ref.listen(eventControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }

      if (!next.isLoading && previous?.isLoading == true && !next.hasError) {
        Navigator.pop(context);
      }
    });

    final controller = ref.watch(eventControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          initialEvent == null
              ? 'Create Event • ${group.name}'
              : 'Edit Event • ${group.name}',
        ),
        actions: [
          if (initialEvent != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Event'),
                      content: const Text(
                        'Are you sure you want to delete this event? This action cannot be undone.',
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

                await ref
                    .read(eventControllerProvider.notifier)
                    .deleteEvent(initialEvent!.id);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: EventForm(
              initialEvent: initialEvent,
              onSubmit: (data) async {
                final bool usesPersonName =
                    data.eventType == EventType.birthday ||
                    data.eventType == EventType.anniversary ||
                    data.eventType == EventType.workAnniversary;

                final title = usesPersonName
                    ? (data.personName ?? '')
                    : (data.title ?? data.eventType.name);

                final event = initialEvent == null
                    ? Event(
                        id: '',
                        groupId: group.id,
                        title: title,
                        personName: data.personName,
                        eventType: data.eventType,
                        eventDate: data.eventDate,
                        repeatType: data.repeatType,
                        notifyBefore: data.notifyBefore,
                        notes: data.notes,
                        createdBy: user.uid,
                        createdByName:
                            user.displayName ?? user.email ?? 'Unknown User',
                        createdAt: DateTime.now(),
                        isActive: true,
                      )
                    : initialEvent!.copyWith(
                        title: title,
                        personName: data.personName,
                        eventType: data.eventType,
                        eventDate: data.eventDate,
                        repeatType: data.repeatType,
                        notifyBefore: data.notifyBefore,
                        notes: data.notes,
                      );

                final controller = ref.read(eventControllerProvider.notifier);

                if (initialEvent == null) {
                  await controller.createEvent(event);
                } else {
                  await controller.updateEvent(event);
                }
              },
            ),
          ),

          if (controller.isLoading)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
