import 'package:remind_circle/features/auth/data/repositories/auth_repository.dart';
import 'package:remind_circle/features/user/data/repositories/user_repository.dart';
import 'package:remind_circle/features/user/domain/models/user_profile.dart';

class UserProfileService {
  UserProfileService({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  Future<void> syncCurrentUser() async {
    final user = _authRepository.getCurrentUser();

    if (user == null) return;

    final exists = await _userRepository.userExists(user.uid);

    final now = DateTime.now();

    if (!exists) {
      final profile = UserProfile(
        uid: user.uid,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        createdAt: now,
        updatedAt: now,
      );

      await _userRepository.createUser(profile);
    } else {
      final existing = await _userRepository.getUser(user.uid);

      if (existing == null) return;

      final updated = UserProfile(
        uid: existing.uid,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        createdAt: existing.createdAt,
        updatedAt: now,
      );

      await _userRepository.updateUser(updated);
    }
  }
}
