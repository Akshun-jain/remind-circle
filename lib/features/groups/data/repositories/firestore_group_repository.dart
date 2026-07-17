import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/data/repositories/group_repository.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

class FirestoreGroupRepository implements GroupRepository {
  FirestoreGroupRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  static const _characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateInviteCode() {
    final random = Random();

    return List.generate(
      6,
      (_) => _characters[random.nextInt(_characters.length)],
    ).join();
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String ownerId,
  }) async {
    final doc = _firestoreService.groups.doc();

    final group = Group(
      id: doc.id,
      name: name,
      ownerId: ownerId,
      memberIds: [ownerId],
      inviteCode: _generateInviteCode(),
      createdAt: DateTime.now(),
    );

    await doc.set(group.toMap());

    return group;
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    final doc = await _firestoreService.groups.doc(groupId).get();

    if (!doc.exists) return null;

    return Group.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<Group?> getGroupByInviteCode(String inviteCode) async {
    final snapshot = await _firestoreService.groups
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;

    return Group.fromMap(doc.id, doc.data());
  }

  @override
  Future<void> joinGroup({
    required String inviteCode,
    required String userId,
  }) async {
    final group = await getGroupByInviteCode(inviteCode);

    if (group == null) {
      throw Exception('Group not found.');
    }

    if (group.memberIds.contains(userId)) {
      return;
    }

    await _firestoreService.groups.doc(group.id).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _firestoreService.groups.doc(groupId).delete();
  }
}
