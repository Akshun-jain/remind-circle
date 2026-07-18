import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';

class EventFormData {
  final EventType eventType;
  final String? personName;
  final String? title;
  final DateTime eventDate;
  final RepeatType repeatType;
  final List<int> notifyBefore;
  final String? notes;

  const EventFormData({
    required this.eventType,
    this.personName,
    this.title,
    required this.eventDate,
    required this.repeatType,
    required this.notifyBefore,
    this.notes,
  });
}
