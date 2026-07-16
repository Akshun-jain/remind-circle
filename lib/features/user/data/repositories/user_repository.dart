import 'package:remind_circle/features/user/domain/models/user_profile.dart';

abstract class UserRepository {
  Future<void> createUser(UserProfile profile);

  Future<UserProfile?> getUser(String uid);

  Future<bool> userExists(String uid);

  Future<void> updateUser(UserProfile profile);
}
