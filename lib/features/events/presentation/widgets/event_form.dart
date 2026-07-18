import 'package:flutter/material.dart';
import 'package:remind_circle/core/constants/event_constants.dart';
import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';
import 'package:remind_circle/features/events/presentation/models/event_form_data.dart';

class EventForm extends StatefulWidget {
  final void Function(EventFormData data) onSubmit;

  const EventForm({super.key, required this.onSubmit});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  EventType _eventType = EventType.birthday;
  RepeatType _repeatType = RepeatType.yearly;

  DateTime _eventDate = DateTime.now();

  final _personController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  final Set<int> _notifyBefore = {0};

  @override
  void dispose() {
    _personController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit(
      EventFormData(
        eventType: _eventType,
        personName: _personController.text.trim().isEmpty
            ? null
            : _personController.text.trim(),
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        eventDate: _eventDate,
        repeatType: _repeatType,
        notifyBefore: _notifyBefore.toList()..sort(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  bool get _requiresPersonName {
    return _eventType == EventType.birthday ||
        _eventType == EventType.anniversary ||
        _eventType == EventType.workAnniversary;
  }

  bool get _requiresCustomTitle {
    return _eventType == EventType.custom;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEventTypeDropdown(),

          const SizedBox(height: 16),

          if (_requiresPersonName) _buildPersonNameField(),

          if (_requiresPersonName) const SizedBox(height: 16),

          if (_requiresCustomTitle) _buildTitleField(),

          if (_requiresCustomTitle) const SizedBox(height: 16),

          _buildDatePicker(),

          const SizedBox(height: 16),

          _buildRepeatDropdown(),

          const SizedBox(height: 16),

          _buildReminderChips(),

          const SizedBox(height: 16),

          _buildNotesField(),

          const SizedBox(height: 24),

          FilledButton(onPressed: _submit, child: const Text('Save Event')),
        ],
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return DropdownButtonFormField<EventType>(
      initialValue: _eventType,
      decoration: const InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(),
      ),
      items: EventConstants.eventTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_labelForEventType(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _eventType = value;
        });
      },
    );
  }

  Widget _buildPersonNameField() {
    return TextFormField(
      controller: _personController,
      decoration: const InputDecoration(
        labelText: 'Person Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_requiresPersonName && (value == null || value.trim().isEmpty)) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_requiresCustomTitle && (value == null || value.trim().isEmpty)) {
          return 'Please enter an event title';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.grey),
      ),
      leading: const Icon(Icons.calendar_today),
      title: const Text('Event Date'),
      subtitle: Text(
        '${_eventDate.day}/${_eventDate.month}/${_eventDate.year}',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _eventDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() {
            _eventDate = picked;
          });
        }
      },
    );
  }

  Widget _buildRepeatDropdown() {
    return DropdownButtonFormField<RepeatType>(
      initialValue: _repeatType,
      decoration: const InputDecoration(
        labelText: 'Repeat',
        border: OutlineInputBorder(),
      ),
      items: EventConstants.repeatTypes.map((repeat) {
        return DropdownMenuItem(
          value: repeat,
          child: Text(_labelForRepeatType(repeat)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _repeatType = value;
        });
      },
    );
  }

  String _labelForRepeatType(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.none:
        return 'Does not repeat';

      case RepeatType.monthly:
        return 'Every Month';

      case RepeatType.yearly:
        return 'Every Year';
    }
  }

  Widget _buildReminderChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notify Before',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: EventConstants.reminderOptions.map((days) {
            return FilterChip(
              label: Text(
                days == 0 ? 'Same Day' : '$days Day${days > 1 ? 's' : ''}',
              ),
              selected: _notifyBefore.contains(days),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _notifyBefore.add(days);
                  } else {
                    _notifyBefore.remove(days);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _labelForEventType(EventType type) {
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
}
