import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/providers/event_repository_provider.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

final groupEventsProvider = StreamProvider.family<List<Event>, String>((
  ref,
  groupId,
) {
  final repository = ref.watch(eventRepositoryProvider);

  return repository.watchGroupEvents(groupId);
});
