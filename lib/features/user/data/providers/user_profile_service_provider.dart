import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/providers/auth_repository_provider.dart';
import 'package:remind_circle/features/user/data/providers/user_repository_provider.dart';
import 'package:remind_circle/features/user/data/services/user_profile_service.dart';

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(
    userRepository: ref.watch(userRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
