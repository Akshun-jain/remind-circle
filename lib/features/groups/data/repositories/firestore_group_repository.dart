import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/data/repositories/group_repository.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
      admins: [ownerId],
    );

    final batch = FirebaseFirestore.instance.batch();

    batch.set(doc, group.toMap());

    final inviteCodeDoc = _firestoreService.inviteCodes.doc(group.inviteCode);

    batch.set(inviteCodeDoc, {'groupId': group.id});

    await batch.commit();

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
    final inviteCodeDoc = await _firestoreService.inviteCodes
        .doc(inviteCode)
        .get(const GetOptions(source: Source.server));

    if (!inviteCodeDoc.exists) {
      throw Exception('Group not found.');
    }

    final data = inviteCodeDoc.data();

    if (data == null) {
      throw Exception('Group not found.');
    }

    final groupId = data['groupId'] as String?;

    if (groupId == null) {
      throw Exception('Invalid invite code.');
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('You must be signed in.');
    }

    if (currentUser.uid != userId) {
      throw Exception('Authentication mismatch.');
    }

    await _firestoreService.groups.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([currentUser.uid]),
    });
  }

  @override
  Future<void> promoteToAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _firestoreService.groups.doc(groupId).update({
      'admins': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    final groupEvents = _firestoreService.groupEvents(groupId);

    final snapshot = await groupEvents.get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestoreService.groups.doc(groupId));

    await batch.commit();
  }

  @override
  Stream<Group?> watchGroup(String groupId) {
    return _firestoreService.groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }

      return Group.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Future<void> demoteAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _firestoreService.groups.doc(groupId).update({
      'admins': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _firestoreService.groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'admins': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _firestoreService.groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'admins': FieldValue.arrayRemove([userId]),
    });
  }
}
