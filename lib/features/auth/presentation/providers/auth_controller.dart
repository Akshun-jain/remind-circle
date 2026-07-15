import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/providers/auth_repository_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);

      await repository.signInWithGoogle();
    });
  }
}
