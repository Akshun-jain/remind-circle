import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/home/data/repositories/home_repository.dart';

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
}
