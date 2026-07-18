import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/core/services/firestore_service.dart';
import 'package:remind_circle/features/events/data/repositories/event_repository.dart';
import 'package:remind_circle/features/events/data/repositories/firestore_event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return FirestoreEventRepository(
    FirestoreService(),
  );
});
