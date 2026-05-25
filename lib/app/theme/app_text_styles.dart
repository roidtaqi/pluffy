import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Premium serif style titles (can fall back to default serif/system font with beautiful spacing)
  static const TextStyle brandHeader = TextStyle(
    fontFamily: 'serif',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textMain,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body Texts
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
    height: 1.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySecondaryMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Utility Labels
  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  static const TextStyle priceRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle loyaltyPointsText = TextStyle(
    fontFamily: 'serif',
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1.1,
  );
}
