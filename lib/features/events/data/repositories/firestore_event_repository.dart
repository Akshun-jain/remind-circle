import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/events/data/repositories/event_repository.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class FirestoreEventRepository implements EventRepository {
  final FirestoreService _firestoreService;

  FirestoreEventRepository(this._firestoreService);

  @override
  Future<void> createEvent(Event event) async {
    final doc = _firestoreService.events.doc();

    await doc.set(
      Event(
        id: doc.id,
        groupId: event.groupId,
        title: event.title,
        personName: event.personName,
        eventType: event.eventType,
        eventDate: event.eventDate,
        repeatType: event.repeatType,
        notifyBefore: event.notifyBefore,
        notes: event.notes,
        createdBy: event.createdBy,
        createdByName: event.createdByName,
        createdAt: event.createdAt,
        isActive: event.isActive,
      ).toMap(),
    );
  }

  @override
  Stream<List<Event>> watchGroupEvents(String groupId) {
    return _firestoreService.events
        .where('groupId', isEqualTo: groupId)
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
    await _firestoreService.events.doc(event.id).update(event.toMap());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.events.doc(eventId).delete();
  }
}
