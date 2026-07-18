import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

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

      await repository.createEvent(event);
    });
  }
}
