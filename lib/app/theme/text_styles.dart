import 'package:flutter/material.dart';
import 'package:remind_circle/app/theme/colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(fontSize: 16, color: AppColors.textSecondary);
}
