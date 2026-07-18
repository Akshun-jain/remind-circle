import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';

class EventConstants {
  static const reminderOptions = [0, 1, 3, 7, 30];

  static const repeatTypes = [
    RepeatType.none,
    RepeatType.monthly,
    RepeatType.yearly,
  ];

  static const eventTypes = [
    EventType.birthday,
    EventType.anniversary,
    EventType.workAnniversary,
    EventType.meeting,
    EventType.festival,
    EventType.holiday,
    EventType.custom,
  ];
}
