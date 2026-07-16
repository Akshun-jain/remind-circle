import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/core/providers/auth_repository_provider.dart';
import 'package:remind_circle/features/auth/domain/models/app_user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return repository.authStateChanges();
});
