import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/core/providers/home_repository_provider.dart';
import 'package:remind_circle/core/utils/next_occurrence_helper.dart';

import 'package:remind_circle/features/events/domain/models/event.dart';

final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final authState = ref.watch(authStateProvider);

  final user = authState.value;

  if (user == null) {
    return [];
  }

  final repository = ref.read(homeRepositoryProvider);

  final events = await repository.upcomingEvents(user.uid);

  final today = DateTime.now();

  final upcoming = events.where((event) {
    final nextDate = NextOccurrenceHelper.getNextOccurrence(
      eventDate: event.eventDate,
      repeatType: event.repeatType,
    );

    return !nextDate.isBefore(DateTime(today.year, today.month, today.day));
  }).toList();

  upcoming.sort((a, b) {
    final nextA = NextOccurrenceHelper.getNextOccurrence(
      eventDate: a.eventDate,
      repeatType: a.repeatType,
    );

    final nextB = NextOccurrenceHelper.getNextOccurrence(
      eventDate: b.eventDate,
      repeatType: b.repeatType,
    );

    return nextA.compareTo(nextB);
  });

  return upcoming.take(3).toList();
});
