import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // iOS Colors
  static const Color background = Color(0xFFF2F2F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color secondaryBlue = Color(0xFF5AC8FA);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  
  // Glassmorphism shadow
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.7),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  static BoxDecoration glassDecoration = BoxDecoration(
    color: glassWhite,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: glassBorder,
      width: 1,
    ),
    boxShadow: glassShadow,
  );

  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
