import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';
import 'package:remind_circle/features/home/presentation/providers/upcoming_events_provider.dart';

final eventControllerProvider = AsyncNotifierProvider<EventController, void>(
  EventController.new,
);

class EventController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Event> createEvent(Event event) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(eventRepositoryProvider);

      // Firestore can queue writes locally while the device is offline.
      // The event save itself is the operation the user is waiting for.
      final savedEvent = await repository.createEvent(event);

      // Notification scheduling must not block the Save UI.
      unawaited(
        NotificationService.instance
            .scheduleEventNotifications(savedEvent)
            .catchError((error, stackTrace) {
              developer.log(
                'Failed to schedule event notification',
                error: error,
                stackTrace: stackTrace,
              );
            }),
      );

      state = const AsyncData(null);

      ref.invalidate(upcomingEventsProvider);

      return savedEvent;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
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
