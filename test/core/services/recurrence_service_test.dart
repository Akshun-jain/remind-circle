import 'package:flutter_test/flutter_test.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';
import 'package:remind_circle/features/events/domain/enums/event_type.dart';
import 'package:remind_circle/features/events/domain/enums/repeat_type.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

Event makeMonthlyEvent(DateTime date) {
  return Event(
    id: 'test',
    groupId: 'group',
    title: 'Month End Test',
    eventType: EventType.other,
    eventDate: date,
    eventTime: date,
    repeatType: RepeatType.monthly,
    notifyBefore: const [0],
    notes: null,
    createdBy: 'test',
    createdByName: 'Test',
    createdAt: DateTime(2026, 1, 1),
    isActive: true,
  );
}

void main() {
  test('January 31 rolls to February 28', () {
    final event = makeMonthlyEvent(DateTime(2026, 1, 31, 22));

    final result = RecurrenceService.getNextOccurrence(
      event,
      now: DateTime(2026, 2, 1),
    );

    expect(result, DateTime(2026, 2, 28, 22));
  });

  test('August 31 rolls to September 30', () {
    final event = makeMonthlyEvent(DateTime(2026, 8, 31, 22));

    final result = RecurrenceService.getNextOccurrence(
      event,
      now: DateTime(2026, 9, 1),
    );

    expect(result, DateTime(2026, 9, 30, 22));
  });

  test('October 31 rolls to November 30', () {
    final event = makeMonthlyEvent(DateTime(2026, 10, 31, 22));

    final result = RecurrenceService.getNextOccurrence(
      event,
      now: DateTime(2026, 11, 1),
    );

    expect(result, DateTime(2026, 11, 30, 22));
  });

  test('November 30 remains November 30 for current month', () {
    final event = makeMonthlyEvent(DateTime(2026, 11, 30, 22));

    final result = RecurrenceService.getNextOccurrence(
      event,
      now: DateTime(2026, 11, 1),
    );

    expect(result, DateTime(2026, 11, 30, 22));
  });
}
