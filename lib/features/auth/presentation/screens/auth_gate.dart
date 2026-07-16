import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:remind_circle/features/auth/presentation/screens/welcome_screen.dart';
import 'package:remind_circle/features/home/presentation/screens/home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          const Scaffold(body: Center(child: Text('Something went wrong'))),
    );
  }
}
