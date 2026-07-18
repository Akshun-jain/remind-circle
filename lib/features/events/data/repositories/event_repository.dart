import 'package:remind_circle/features/events/domain/models/event.dart';

abstract class EventRepository {
  Future<void> createEvent(Event event);

  Stream<List<Event>> getEvents(String groupId);

  Future<void> deleteEvent(String eventId, String groupId);

  Future<void> toggleEvent(String eventId, String groupId, bool completed);
}
