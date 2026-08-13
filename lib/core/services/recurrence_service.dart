import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class RecurrenceService {
  const RecurrenceService._();

  static DateTime? getNextOccurrence(Event event) {
    final now = DateTime.now();

    final eventTime =
        event.eventTime ??
        DateTime(
          event.eventDate.year,
          event.eventDate.month,
          event.eventDate.day,
          9,
          0,
        );

    switch (event.repeatType) {
      case RepeatType.none:
        return eventTime.isAfter(now) ? eventTime : null;

      case RepeatType.monthly:
        return _nextMonthly(eventTime, now);

      case RepeatType.yearly:
        return _nextYearly(eventTime, now);
    }
  }

  static DateTime _nextMonthly(DateTime eventTime, DateTime now) {
    var year = now.year;
    var month = now.month;

    while (true) {
      final lastDay = DateTime(year, month + 1, 0).day;

      final day = eventTime.day <= lastDay ? eventTime.day : lastDay;

      final candidate = DateTime(
        year,
        month,
        day,
        eventTime.hour,
        eventTime.minute,
      );

      if (candidate.isAfter(now)) {
        return candidate;
      }

      month++;

      if (month > 12) {
        month = 1;
        year++;
      }
    }
  }

  static DateTime _nextYearly(DateTime eventTime, DateTime now) {
    var next = DateTime(
      now.year,
      eventTime.month,
      eventTime.day,
      eventTime.hour,
      eventTime.minute,
    );

    if (!next.isAfter(now)) {
      next = DateTime(
        now.year + 1,
        eventTime.month,
        eventTime.day,
        eventTime.hour,
        eventTime.minute,
      );
    }

    return next;
  }
}
