import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';

abstract class HomeRepository {
  Stream<List<Group>> myGroups(String userId);

  Future<List<Event>> upcomingEvents(String userId);
  Future<List<Event>> allActiveEvents(String userId);
}
