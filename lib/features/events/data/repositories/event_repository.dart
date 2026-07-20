import 'package:remind_circle/features/events/domain/models/event.dart';

abstract class EventRepository {
  Future<void> createEvent(Event event);

  Stream<List<Event>> watchGroupEvents(String groupId);

  Future<void> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);
}
