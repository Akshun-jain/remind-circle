import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';

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
    });
  }

  Future<void> updateEvent({
    required Event oldEvent,
    required Event newEvent,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);

      // Cancel notifications scheduled for the old event
      await NotificationService.instance.cancelEventNotifications(oldEvent.id);

      // Save the updated event
      await repository.updateEvent(newEvent);

      // Schedule notifications for the updated event
      await NotificationService.instance.scheduleEventNotifications(newEvent);
    });
  }

  Future<void> deleteEvent(Event event) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);

      await NotificationService.instance.cancelEventNotifications(event.id);

      await repository.deleteEvent(event.id);
    });
  }
}
