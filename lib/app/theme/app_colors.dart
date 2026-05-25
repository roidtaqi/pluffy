import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Warm Dessert Palette
  static const Color primary = Color(0xFF9B1B1B);       // Deep Crimson (Cherry/Strawberry)
  static const Color background = Color(0xFFFBF7F0);    // Warm Cream (Main background)
  static const Color cardBg = Color(0xFFFAF0DC);        // Almond Custard (Cards and Containers)
  static const Color border = Color(0xFFE8C9A0);        // Golden Biscuit (Borders/Dividers)
  static const Color accent = Color(0xFFF4A58A);        // Peach Coral (Promos and Highlights)
  static const Color textMain = Color(0xFF2C1E1B);      // Dark Cacao (Main Titles & Heavy Text)
  static const Color textSecondary = Color(0xFF7D6F6C); // Chestnut Grey (Secondary/Subtexts)

  // Status & Utility Colors
  static const Color success = Color(0xFF4E7D56);       // Warm Pistachio Green
  static const Color error = Color(0xFFC94A4A);         // Bright Berry Red
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Custom Gradients for Premium Feel
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9B1B1B),
      Color(0xFFB82F2F),
    ],
  );

  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4A58A),
      Color(0xFFFAF0DC),
    ],
  );
}
