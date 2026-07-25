import 'package:remind_circle/features/events/domain/models/event.dart';

abstract class EventRepository {
  Future<Event> createEvent(Event event);

  Future<List<Event>> getAllActiveEvents();

  Stream<List<Event>> watchGroupEvents(String groupId);

  Future<void> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);
}
