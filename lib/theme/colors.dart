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
  static const Color pureBoldShadowLight = Color(0xFF111827);

  // Pure & Bold — Dark Mode
  static const Color pureBoldBackgroundDark = Color(0xFF111827);
  static const Color pureBoldPrimaryDark = Color(0xFFF9FAFB);
  static const Color pureBoldAccentDark = Color(0xFF3B82F6);
  static const Color pureBoldSurfaceDark = Color(0xFF1F2937);
  static const Color pureBoldOnBackgroundDark = Color(0xFFF9FAFB);
  static const Color pureBoldShadowDark = Color.fromRGBO(249, 250, 251, 0.75);

  // Modern / Techy Theme
  static const Color techyBackground = Color(0xFF0D0F1A);
  static const Color techyPrimary = Color(0xFF4D7FFF);
  static const Color techyAccent = Color(0xFF00E5C0);
  static const Color techySurface = Color(0xFF1A1D2E);
  static const Color techyShadowDark = Color.fromRGBO(205, 214, 244, 0.70);
  static const Color techyShadowLight = Color(0xFF0D0F1A);

  // Friendly / Human Theme
  static const Color friendlyBackground = Color(0xFFFFF8F2);
  static const Color friendlyPrimary = Color(0xFFFF6B35);
  static const Color friendlyAccent = Color(0xFFFFD166);
  static const Color friendlySurface = Color(0xFFFFF0E8);
  static const Color friendlyShadowLight = Color(0xFF2C1810);
  static const Color friendlyShadowDark = Color.fromRGBO(255, 240, 232, 0.70);

  // Corporate / Minimal Theme
  static const Color corporateBackground = Color(0xFFFFFFFF);
  static const Color corporatePrimary = Color(0xFF1E1E2E);
  static const Color corporateAccent = Color(0xFF6C63FF);
  static const Color corporateSurface = Color(0xFFF8F8FC);
  static const Color corporateShadowLight = Color(0xFF1E1E2E);
  static const Color corporateShadowDark = Color.fromRGBO(232, 231, 245, 0.70);

  // Playful Theme
  static const Color playfulBackground = Color(0xFF1A0A2E);
  static const Color playfulPrimary = Color(0xFFFF4DAF);
  static const Color playfulAccent = Color(0xFFB44FFF);
  static const Color playfulSurface = Color(0xFF2D1045);
  static const Color playfulShadowDark = Color.fromRGBO(245, 208, 255, 0.70);
  static const Color playfulShadowLight = Color(0xFF1A0A2E);

  // Trailblazer Theme
  static const Color trailblazerBackground = Color(0xFF0F172A); // Navy Blue
  static const Color trailblazerPrimary = Color(0xFFFACC15); // Gold
  static const Color trailblazerAccent = Color(0xFFFACC15); // Gold
  static const Color trailblazerSurface = Color(0xFF1E293B); // Lighter Navy
  static const Color trailblazerShadowDark = Color(0xFF000000); // Black shadow
  static const Color trailblazerShadowLight = Color(0xFF000000); 

  // Monochrome Theme (Pure black & white, minimal)
  static const Color monochromeBackgroundLight = Color(0xFFFFFFFF);
  static const Color monochromePrimaryLight = Color(0xFF000000);
  static const Color monochromeAccentLight = Color(0xFF000000);
  static const Color monochromeSurfaceLight = Color(0xFFF5F5F5);
  static const Color monochromeOnBackgroundLight = Color(0xFF000000);
  static const Color monochromeShadowLight = Color(0xFF000000);

  static const Color monochromeBackgroundDark = Color(0xFF000000);
  static const Color monochromePrimaryDark = Color(0xFFFFFFFF);
  static const Color monochromeAccentDark = Color(0xFFFFFFFF);
  static const Color monochromeSurfaceDark = Color(0xFF1A1A1A);
  static const Color monochromeOnBackgroundDark = Color(0xFFFFFFFF);
  static const Color monochromeShadowDark = Color.fromRGBO(255, 255, 255, 0.70);

  // CI4 Default Theme (QueueSys monochrome palette with solid borders & zero offset shadows)
  static const Color ci4DefaultBackgroundLight = Color(0xFFFFFFFF);
  static const Color ci4DefaultPrimaryLight = Color(0xFF111110);
  static const Color ci4DefaultAccentLight = Color(0xFF111110);
  static const Color ci4DefaultSurfaceLight = Color(0xFFF7F7F5);
  static const Color ci4DefaultOnBackgroundLight = Color(0xFF111110);
  static const Color ci4DefaultShadowLight = Color(0xFF111110);

  static const Color ci4DefaultBackgroundDark = Color(0xFF111110);
  static const Color ci4DefaultPrimaryDark = Color(0xFFFFFFFF);
  static const Color ci4DefaultAccentDark = Color(0xFFFFFFFF);
  static const Color ci4DefaultSurfaceDark = Color(0xFF1A1A19);
  static const Color ci4DefaultOnBackgroundDark = Color(0xFFFFFFFF);
  static const Color ci4DefaultShadowDark = Color(0xFF555550); 

  // Semantic / Status Colors (shared across all themes)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color queued = Color(0xFF8B5CF6);
  static const Color serving = Color(0xFF10B981);
}

