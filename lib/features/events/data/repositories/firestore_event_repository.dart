import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/events/data/repositories/event_repository.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class FirestoreEventRepository implements EventRepository {
  final FirestoreService _firestoreService;

  FirestoreEventRepository(this._firestoreService);

  @override
  Future<Event> createEvent(Event event) async {
    final doc = _firestoreService.groupEvents(event.groupId).doc();

    final savedEvent = Event(
      id: doc.id,
      groupId: event.groupId,
      title: event.title,
      personName: event.personName,
      eventType: event.eventType,
      eventDate: event.eventDate,
      eventTime: event.eventTime,
      repeatType: event.repeatType,
      notifyBefore: event.notifyBefore,
      notes: event.notes,
      createdBy: event.createdBy,
      createdByName: event.createdByName,
      createdAt: event.createdAt,
      isActive: event.isActive,
    );

    await doc.set(savedEvent.toMap());

    return savedEvent;
  }

  @override
  Stream<List<Event>> watchGroupEvents(String groupId) {
    return _firestoreService
        .groupEvents(groupId)
        .orderBy('eventDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _firestoreService
        .groupEvents(event.groupId)
        .doc(event.id)
        .update(event.toMap());
  }

  @override
  Future<void> deleteEvent({
    required String groupId,
    required String eventId,
  }) async {
    await _firestoreService.groupEvents(groupId).doc(eventId).delete();
  }
}
