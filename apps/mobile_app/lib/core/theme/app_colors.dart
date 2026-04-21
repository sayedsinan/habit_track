import 'package:flutter/material.dart';

class AppColors {
  // --- Light Mode Palette ---
  static const Color lightBg          = Color(0xFFFDFBF7);
  static const Color lightSurface     = Color(0xFFF3F2EF);
  static const Color lightTextPrimary = Color(0xFF1F1E1C);
  static const Color lightTextSecondary = Color(0xFF696763);
  static const Color lightBorder      = Color(0xFFE6E4DF);
  static const Color lightAccent      = Color(0xFFDA7756); // Terracotta
  static const Color lightSecondary   = Color(0xFF3A6962); // Sage
  static const Color lightError       = Color(0xFFB73D35);

  // --- Dark Mode Palette ---
  static const Color darkBg           = Color(0xFF1F1E1C);
  static const Color darkSurface      = Color(0xFF2D2C2A);
  static const Color darkTextPrimary  = Color(0xFFF3F2EF);
  static const Color darkTextSecondary = Color(0xFFA3A19D);
  static const Color darkBorder       = Color(0xFF3C3B39);
  static const Color darkAccent       = Color(0xFFE28A6F); // Brightened Terracotta
  static const Color darkSecondary    = Color(0xFF588B83); // Lightened Sage
  static const Color darkError        = Color(0xFFD45B53);

  // Status Colors (Common)
  static const Color success          = Color(0xFF10B981);
  static const Color warning          = Color(0xFFF59E0B);

  // Helper getters for current theme (defaulting to dark as requested previously or based on app state)
  // However, it's better to use Theme.of(context) in widgets.
}