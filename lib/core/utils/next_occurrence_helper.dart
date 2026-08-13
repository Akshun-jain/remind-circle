import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';

class NextOccurrenceHelper {
  const NextOccurrenceHelper._();

  static DateTime getNextOccurrence({
    required DateTime eventDate,
    required RepeatType repeatType,
  }) {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);

    switch (repeatType) {
      case RepeatType.none:
        return eventDate;

      case RepeatType.yearly:
        return _nextYearlyOccurrence(eventDate, now);

      case RepeatType.monthly:
        return _nextMonthlyOccurrence(eventDate, now);
    }
  }

  static DateTime _nextYearlyOccurrence(DateTime eventDate, DateTime today) {
    final year = today.year;

    DateTime next = _safeDate(year, eventDate.month, eventDate.day);

    if (next.isBefore(today)) {
      next = _safeDate(year + 1, eventDate.month, eventDate.day);
    }

    return next;
  }

  static DateTime _nextMonthlyOccurrence(DateTime eventDate, DateTime today) {
    int year = today.year;
    int month = today.month;

    DateTime next = _safeDate(year, month, eventDate.day);

    if (next.isBefore(today)) {
      month++;

      if (month > 12) {
        month = 1;
        year++;
      }

      next = _safeDate(year, month, eventDate.day);
    }

    return next;
  }

  static DateTime _safeDate(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;

    return DateTime(year, month, day > lastDay ? lastDay : day);
  }
}
