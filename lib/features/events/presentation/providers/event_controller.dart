import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';
import 'package:remind_circle/features/home/presentation/providers/upcoming_events_provider.dart';

//import 'package:remind_circle/features/home/presentation/providers/upcoming_events_provider.dart';

final eventControllerProvider = AsyncNotifierProvider<EventController, void>(
  EventController.new,
);

class EventController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createEvent(Event event) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);

      final savedEvent = await repository.createEvent(event);

      await NotificationService.instance.scheduleEventNotifications(savedEvent);

      //ref.invalidate(upcomingEventsProvider);
    });

    if (!state.hasError) {
      ref.invalidate(upcomingEventsProvider);
    }
  }

  Future<void> updateEvent({
    required Event oldEvent,
    required Event newEvent,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);

      await repository.updateEvent(newEvent);

      await NotificationService.instance.scheduleEventNotifications(newEvent);
    });

    if (!state.hasError) {
      ref.invalidate(upcomingEventsProvider);
    }
  }

  Future<void> deleteEvent(Event event) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);

      await repository.deleteEvent(groupId: event.groupId, eventId: event.id);

      await NotificationService.instance.cancelEventNotifications(event.id);
    });

    if (!state.hasError) {
      ref.invalidate(upcomingEventsProvider);
    }
  }
}
