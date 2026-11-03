import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Application theme configurations for Light and Dark modes
class AppThemeData {
  AppThemeData._();

  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;
}

