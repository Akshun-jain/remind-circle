import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/app/theme/colors.dart';
import 'package:remind_circle/app/theme/spacing.dart';
import 'package:remind_circle/app/theme/text_styles.dart';
import 'package:remind_circle/core/constants/app_strings.dart';
import 'package:remind_circle/features/auth/presentation/providers/auth_controller.dart';
import 'package:remind_circle/shared/components/primary_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                'assets/images/logos/remind_circle_logo.png',
                height: 120,
              ),

              const SizedBox(height: AppSpacing.xl),

              const Text(
                AppStrings.welcomeTitle,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              const Text(
                AppStrings.welcomeSubtitle,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              PrimaryButton(
                text: AppStrings.continueWithGoogle,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle();
                      },
                icon: const Icon(Icons.login),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Text(
                AppStrings.termsAndPrivacy,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
