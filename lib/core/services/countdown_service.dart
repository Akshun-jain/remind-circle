import 'package:remind_circle/core/services/recurrence_service.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class CountdownService {
  const CountdownService._();

  static String getCountdownLabel(Event event) {
    final occurrence = RecurrenceService.getNextOccurrence(event);

    if (occurrence == null) {
      return 'Completed';
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final eventDate = DateTime(
      occurrence.year,
      occurrence.month,
      occurrence.day,
    );

    final difference = eventDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Tomorrow';
    }

    if (difference < 7) {
      return 'In $difference days';
    }

    if (difference < 30) {
      final weeks = (difference / 7).ceil();
      return 'In $weeks week${weeks > 1 ? 's' : ''}';
    }

    if (difference < 365) {
      final months = (difference / 30).ceil();
      return 'In $months month${months > 1 ? 's' : ''}';
    }

    final years = (difference / 365).ceil();

    return 'In $years year${years > 1 ? 's' : ''}';
  }
}
