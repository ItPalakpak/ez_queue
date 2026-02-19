import 'package:flutter/material.dart';

/// Color tokens for all theme variants.
/// Each theme variant has light and dark mode colors.
class EZColors {
  // Pure & Bold — Light Mode
  static const Color pureBoldBackgroundLight = Color(0xFFFFFFFF);
  static const Color pureBoldPrimaryLight = Color(0xFF111827);
  static const Color pureBoldAccentLight = Color(0xFF2563EB);
  static const Color pureBoldSurfaceLight = Color(0xFFF5F7FF);
  static const Color pureBoldOnBackgroundLight = Color(0xFF111827);

  // Pure & Bold — Dark Mode
  static const Color pureBoldBackgroundDark = Color(0xFF111827);
  static const Color pureBoldPrimaryDark = Color(0xFFF9FAFB);
  static const Color pureBoldAccentDark = Color(0xFF3B82F6);
  static const Color pureBoldSurfaceDark = Color(0xFF1F2937);
  static const Color pureBoldOnBackgroundDark = Color(0xFFF9FAFB);

  // Modern / Techy Theme
  static const Color techyBackground = Color(0xFF0D0F1A);
  static const Color techyPrimary = Color(0xFF4D7FFF);
  static const Color techyAccent = Color(0xFF00E5C0);
  static const Color techySurface = Color(0xFF1A1D2E);

  // Friendly / Human Theme
  static const Color friendlyBackground = Color(0xFFFFF8F2);
  static const Color friendlyPrimary = Color(0xFFFF6B35);
  static const Color friendlyAccent = Color(0xFFFFD166);
  static const Color friendlySurface = Color(0xFFFFF0E8);

  // Corporate / Minimal Theme
  static const Color corporateBackground = Color(0xFFFFFFFF);
  static const Color corporatePrimary = Color(0xFF1E1E2E);
  static const Color corporateAccent = Color(0xFF6C63FF);
  static const Color corporateSurface = Color(0xFFF8F8FC);

  // Playful Theme
  static const Color playfulBackground = Color(0xFF1A0A2E);
  static const Color playfulPrimary = Color(0xFFFF4DAF);
  static const Color playfulAccent = Color(0xFFB44FFF);
  static const Color playfulSurface = Color(0xFF2D1045);

  // Semantic / Status Colors (shared across all themes)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color queued = Color(0xFF8B5CF6);
  static const Color serving = Color(0xFF10B981);
}

