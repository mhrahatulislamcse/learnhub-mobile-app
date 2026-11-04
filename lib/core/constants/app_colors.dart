import 'package:flutter/material.dart';

/// Defines the design palette and colors matching the LearnHub Figma Design Kit.
class AppColors {
  AppColors._();

  // Primary Palette (Figma #142B4D & #3978D5)
  static const Color primary = Color(0xFF142B4D); // Midnight Navy (Brand)
  static const Color primaryDark = Color(0xFF0D1E36);
  static const Color primaryLight = Color(0xFF284B79);

  // Secondary & Interactive Palette
  static const Color secondary = Color(0xFF3978D5); // Interactive Royal Blue
  static const Color secondaryLight = Color(0xFF5D93E0);
  static const Color interactiveBlue = Color(0xFF3978D5);
  static const Color pillBlue = Color(0xFFEAF1FC); // Soft blue background for icons/avatars

  // Accent & Stars (Figma #F4B860)
  static const Color accent = Color(0xFFF4B860); // Warm Gold
  static const Color accentGold = Color(0xFFF4B860);

  // Feedback & Action Colors
  static const Color success = Color(0xFF2E9B72); // Figma Green
  static const Color warning = Color(0xFFF4B860);
  static const Color error = Color(0xFFC34E5B); // Figma Red / Sign out
  static const Color danger = Color(0xFFC34E5B);
  static const Color heartPink = Color(0xFFD85D72); // Figma Heart Pink
  static const Color info = Color(0xFF3978D5);

  // Light Theme Neutrals (Figma #F5F7FB canvas)
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF142B4D);
  static const Color lightTextSecondary = Color(0xFF738198);
  static const Color lightBorder = Color(0xFFE7ECF3);
  static const Color lightDivider = Color(0xFFE7ECF3);
  static const Color placeholder = Color(0xFF9AA6B7);

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);

  // Pastel Book Cover Palettes (Figma vector illustrations)
  static const Color coverBlue = Color(0xFFDCE8F8);
  static const Color coverBlueText = Color(0xFF284B79);

  static const Color coverPeach = Color(0xFFF8E8D0);
  static const Color coverPeachText = Color(0xFF9B6237);

  static const Color coverMint = Color(0xFFE0EFE9);
  static const Color coverMintText = Color(0xFF2D7162);

  static const Color coverPurple = Color(0xFFE8E2F5);
  static const Color coverPurpleText = Color(0xFF61518A);

  static const Color coverPink = Color(0xFFF5E3E6);
  static const Color coverPinkText = Color(0xFF9B4F61);
}
