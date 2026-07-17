import 'package:remind_circle/features/groups/domain/models/group.dart';

abstract class HomeRepository {
  Stream<List<Group>> myGroups(String userId);
}
