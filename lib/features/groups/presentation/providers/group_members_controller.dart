import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

final groupMembersProvider = FutureProvider.family<List<UserProfile>, Group>((
  ref,
  group,
) async {
  final firestoreService = FirestoreService();

  final snapshot = await firestoreService
      .groupMembers(group.id)
      .orderBy('name')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();

    return UserProfile(
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }).toList();
});
