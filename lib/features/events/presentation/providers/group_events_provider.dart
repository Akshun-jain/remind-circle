import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';

final groupEventsProvider = StreamProvider.family<List<Event>, String>((
  ref,
  groupId,
) {
  final authState = ref.watch(authStateProvider);

  // Do not attach Firestore listeners while signed out.
  if (authState.value == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(eventRepositoryProvider);

  return repository.watchGroupEvents(groupId);
});
