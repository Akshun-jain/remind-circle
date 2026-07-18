import 'package:flutter/material.dart';
import 'package:remind_circle/features/events/presentation/models/event_form_data.dart';
import 'package:remind_circle/features/events/presentation/widgets/event_form.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EventForm(
          onSubmit: (EventFormData data) {
            debugPrint(data.eventType.name);
          },
        ),
      ),
    );
  }
}
