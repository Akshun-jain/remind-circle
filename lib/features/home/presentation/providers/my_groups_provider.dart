import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/home/data/providers/home_repository_provider.dart';

final myGroupsProvider = StreamProvider<List<Group>>((ref) {
  final user = FirebaseAuth.instance.currentUser!;

  final repository = ref.watch(homeRepositoryProvider);

  return repository.myGroups(user.uid);
});
