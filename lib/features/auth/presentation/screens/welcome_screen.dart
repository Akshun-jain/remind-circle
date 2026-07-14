import 'package:flutter/material.dart';
import 'package:remind_circle/app/theme/colors.dart';
import 'package:remind_circle/app/theme/spacing.dart';
import 'package:remind_circle/app/theme/text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Welcome to RemindCircle',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              const Text(
                'Shared reminders for families, friends and teams.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Continue with Google'),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Text(
                'By continuing, you agree to our Terms & Privacy Policy.',
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
