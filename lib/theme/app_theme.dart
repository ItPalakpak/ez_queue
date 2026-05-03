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
  trailblazer,
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
  final Color shadowColor;

  const ThemeColors({
    required this.background,
    required this.primary,
    required this.accent,
    required this.surface,
    required this.onBackground,
    required this.shadowColor,
  });
}

class EZThemeExtension extends ThemeExtension<EZThemeExtension> {
  final Color shadowColor;
  final Color? secondaryButtonText;

  const EZThemeExtension({
    required this.shadowColor,
    this.secondaryButtonText,
  });

  @override
  ThemeExtension<EZThemeExtension> copyWith({Color? shadowColor, Color? secondaryButtonText}) {
    return EZThemeExtension(
      shadowColor: shadowColor ?? this.shadowColor,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
    );
  }

  @override
  ThemeExtension<EZThemeExtension> lerp(ThemeExtension<EZThemeExtension>? other, double t) {
    if (other is! EZThemeExtension) {
      return this;
    }
    return EZThemeExtension(
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      secondaryButtonText: Color.lerp(secondaryButtonText, other.secondaryButtonText, t),
    );
  }
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
          shadowColor: EZColors.pureBoldShadowLight,
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
          shadowColor: EZColors.techyShadowLight,
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
          shadowColor: EZColors.friendlyShadowLight,
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
          shadowColor: EZColors.corporateShadowLight,
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.playfulShadowLight,
        ),
      AppThemeVariant.trailblazer => const ThemeColors(
          background: EZColors.trailblazerBackground,
          primary: EZColors.trailblazerPrimary,
          accent: EZColors.trailblazerAccent,
          surface: EZColors.trailblazerSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.trailblazerShadowLight,
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
          shadowColor: EZColors.pureBoldShadowDark,
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
          shadowColor: EZColors.techyShadowDark,
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
          shadowColor: EZColors.friendlyShadowDark,
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
          shadowColor: EZColors.corporateShadowDark,
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.playfulShadowDark,
        ),
      AppThemeVariant.trailblazer => const ThemeColors(
          background: EZColors.trailblazerBackground,
          primary: EZColors.trailblazerPrimary,
          accent: EZColors.trailblazerAccent,
          surface: EZColors.trailblazerSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.trailblazerShadowDark,
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
      ).copyWith(
        onPrimary: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        onSecondary: variant == AppThemeVariant.trailblazer ? Colors.white : null,
      ),
      textTheme: EZTypography.textTheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
      extensions: [
        EZThemeExtension(
          shadowColor: colors.shadowColor,
          secondaryButtonText: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        ),
      ],
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
      ).copyWith(
        onPrimary: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        onSecondary: variant == AppThemeVariant.trailblazer ? Colors.white : null,
      ),
      textTheme: EZTypography.textTheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        elevation: 0,
      ),
      extensions: [
        EZThemeExtension(
          shadowColor: colors.shadowColor,
          secondaryButtonText: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        ),
      ],
    );
  }
}

