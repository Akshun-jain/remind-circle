import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remind_circle/app/theme/colors.dart';
import 'package:remind_circle/app/theme/spacing.dart';
import 'package:remind_circle/app/theme/text_styles.dart';
import 'package:remind_circle/features/auth/presentation/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logos/remind_circle_logo.png',
                  height: 150,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('RemindCircle', style: AppTextStyles.heading),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Never Miss Moments Together',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
