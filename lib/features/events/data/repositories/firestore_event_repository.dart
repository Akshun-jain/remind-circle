import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/events/data/repositories/event_repository.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class FirestoreEventRepository implements EventRepository {
  final FirestoreService _firestoreService;

  FirestoreEventRepository(this._firestoreService);

  CollectionReference<Map<String, dynamic>> _collection(String groupId) {
    return _firestoreService.groups.doc(groupId).collection('events');
  }

  @override
  Future<void> createEvent(Event event) async {
    await _collection(event.groupId).doc(event.id).set(event.toMap());
  }

  @override
  Stream<List<Event>> getEvents(String groupId) {
    return _collection(groupId)
        .orderBy('eventDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> deleteEvent(String eventId, String groupId) async {
    await _collection(groupId).doc(eventId).delete();
  }

  @override
  Future<void> toggleEvent(
    String eventId,
    String groupId,
    bool completed,
  ) async {
    await _collection(groupId).doc(eventId).update({'completed': completed});
  }
}
