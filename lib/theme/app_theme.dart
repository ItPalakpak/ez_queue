import 'package:flutter/material.dart';
import 'package:ez_queue/theme/colors.dart';
import 'package:ez_queue/theme/typography.dart';

/// Theme variant enum for different personality themes.
enum AppThemeVariant {
  pureBold,
  techy,
  friendly,
  corporate,
  playful,
}

/// Theme mode enum for light/dark mode.
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme data class containing color information for a theme variant.
class ThemeColors {
  final Color background;
  final Color primary;
  final Color accent;
  final Color surface;
  final Color onBackground;

  const ThemeColors({
    required this.background,
    required this.primary,
    required this.accent,
    required this.surface,
    required this.onBackground,
  });
}

/// App theme builder class that creates ThemeData for different variants.
class AppTheme {
  /// Get colors for a theme variant in light mode.
  static ThemeColors _lightColors(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.pureBold => const ThemeColors(
          background: EZColors.pureBoldBackgroundLight,
          primary: EZColors.pureBoldPrimaryLight,
          accent: EZColors.pureBoldAccentLight,
          surface: EZColors.pureBoldSurfaceLight,
          onBackground: EZColors.pureBoldOnBackgroundLight,
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
        ),
    };
  }

  /// Get colors for a theme variant in dark mode.
  static ThemeColors _darkColors(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.pureBold => const ThemeColors(
          background: EZColors.pureBoldBackgroundDark,
          primary: EZColors.pureBoldPrimaryDark,
          accent: EZColors.pureBoldAccentDark,
          surface: EZColors.pureBoldSurfaceDark,
          onBackground: EZColors.pureBoldOnBackgroundDark,
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
        ),
    };
  }

  /// Build light theme for a given variant.
  static ThemeData light(AppThemeVariant variant) {
    final colors = _lightColors(variant);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        onSurface: colors.onBackground,
      ),
      textTheme: EZTypography.textTheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
    );
  }

  /// Build dark theme for a given variant.
  static ThemeData dark(AppThemeVariant variant) {
    final colors = _darkColors(variant);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        onSurface: colors.onBackground,
      ),
      textTheme: EZTypography.textTheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
    );
  }
}

