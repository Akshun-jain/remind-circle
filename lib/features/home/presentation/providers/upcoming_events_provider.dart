import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/core/providers/home_repository_provider.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';

import 'package:remind_circle/features/events/domain/models/event.dart';

final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final authState = ref.watch(authStateProvider);

  final user = authState.value;

  if (user == null) {
    return [];
  }

  final repository = ref.read(homeRepositoryProvider);

  final events = await repository.upcomingEvents(user.uid);

  final upcomingWithDates = events
      .map(
        (event) => (
          event: event,
          nextOccurrence: RecurrenceService.getNextOccurrence(event),
        ),
      )
      .where((item) => item.nextOccurrence != null)
      .where((item) => !item.nextOccurrence!.isBefore(DateTime.now()))
      .toList();

  upcomingWithDates.sort(
    (a, b) => a.nextOccurrence!.compareTo(b.nextOccurrence!),
  );

  return upcomingWithDates.take(3).map((item) => item.event).toList();
});
