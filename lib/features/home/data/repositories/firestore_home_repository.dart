import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/home/data/repositories/home_repository.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

class FirestoreHomeRepository implements HomeRepository {
  FirestoreHomeRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Stream<List<Group>> myGroups(String userId) {
    return _firestoreService.groups
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Group.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<Event>> upcomingEvents(String userId) async {
    final groupsSnapshot = await _firestoreService.groups
        .where('memberIds', arrayContains: userId)
        .get();

    final List<Event> events = [];

    for (final group in groupsSnapshot.docs) {
      final eventsSnapshot = await _firestoreService
          .groupEvents(group.id)
          .where('isActive', isEqualTo: true)
          .get();

      events.addAll(
        eventsSnapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data())),
      );
    }

    return events;
  }

  @override
  Future<List<Event>> allActiveEvents(String userId) async {
    final groupsSnapshot = await _firestoreService.groups
        .where('memberIds', arrayContains: userId)
        .get();

    final List<Event> events = [];

    for (final group in groupsSnapshot.docs) {
      final eventsSnapshot = await _firestoreService
          .groupEvents(group.id)
          .where('isActive', isEqualTo: true)
          .get();

      events.addAll(
        eventsSnapshot.docs.map((doc) => Event.fromMap(doc.id, doc.data())),
      );
    }

    return events;
  }
}
