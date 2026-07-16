import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/providers/auth_repository_provider.dart';
import 'package:remind_circle/features/user/data/providers/user_profile_service_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);

      await authRepository.signInWithGoogle();

      final userProfileService = ref.read(userProfileServiceProvider);

      await userProfileService.syncCurrentUser();
    });
  }
}
