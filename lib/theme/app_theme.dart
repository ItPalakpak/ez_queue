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
  monochrome,
  ci4Default,
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
  final Offset shadowOffset;

  const ThemeColors({
    required this.background,
    required this.primary,
    required this.accent,
    required this.surface,
    required this.onBackground,
    required this.shadowColor,
    this.shadowOffset = const Offset(3, 3),
  });
}

class EZThemeExtension extends ThemeExtension<EZThemeExtension> {
  final Color shadowColor;
  final Offset shadowOffset;
  final Color? secondaryButtonText;

  const EZThemeExtension({
    required this.shadowColor,
    this.shadowOffset = const Offset(3, 3),
    this.secondaryButtonText,
  });

  @override
  ThemeExtension<EZThemeExtension> copyWith({
    Color? shadowColor,
    Offset? shadowOffset,
    Color? secondaryButtonText,
  }) {
    return EZThemeExtension(
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
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
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t) ?? shadowOffset,
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
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
          shadowColor: EZColors.techyShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
          shadowColor: EZColors.friendlyShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
          shadowColor: EZColors.corporateShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.playfulShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.trailblazer => const ThemeColors(
          background: EZColors.trailblazerBackground,
          primary: EZColors.trailblazerPrimary,
          accent: EZColors.trailblazerAccent,
          surface: EZColors.trailblazerSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.trailblazerShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.monochrome => const ThemeColors(
          background: EZColors.monochromeBackgroundLight,
          primary: EZColors.monochromePrimaryLight,
          accent: EZColors.monochromeAccentLight,
          surface: EZColors.monochromeSurfaceLight,
          onBackground: EZColors.monochromeOnBackgroundLight,
          shadowColor: EZColors.monochromeShadowLight,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.ci4Default => const ThemeColors(
          background: EZColors.ci4DefaultBackgroundLight,
          primary: EZColors.ci4DefaultPrimaryLight,
          accent: EZColors.ci4DefaultAccentLight,
          surface: EZColors.ci4DefaultSurfaceLight,
          onBackground: EZColors.ci4DefaultOnBackgroundLight,
          shadowColor: EZColors.ci4DefaultShadowLight,
          shadowOffset: Offset.zero, // Zero offset shadow for CI4
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
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.techy => const ThemeColors(
          background: EZColors.techyBackground,
          primary: EZColors.techyPrimary,
          accent: EZColors.techyAccent,
          surface: EZColors.techySurface,
          onBackground: Colors.white,
          shadowColor: EZColors.techyShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.friendly => const ThemeColors(
          background: EZColors.friendlyBackground,
          primary: EZColors.friendlyPrimary,
          accent: EZColors.friendlyAccent,
          surface: EZColors.friendlySurface,
          onBackground: EZColors.pureBoldPrimaryLight,
          shadowColor: EZColors.friendlyShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.corporate => const ThemeColors(
          background: EZColors.corporateBackground,
          primary: EZColors.corporatePrimary,
          accent: EZColors.corporateAccent,
          surface: EZColors.corporateSurface,
          onBackground: EZColors.corporatePrimary,
          shadowColor: EZColors.corporateShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.playful => const ThemeColors(
          background: EZColors.playfulBackground,
          primary: EZColors.playfulPrimary,
          accent: EZColors.playfulAccent,
          surface: EZColors.playfulSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.playfulShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.trailblazer => const ThemeColors(
          background: EZColors.trailblazerBackground,
          primary: EZColors.trailblazerPrimary,
          accent: EZColors.trailblazerAccent,
          surface: EZColors.trailblazerSurface,
          onBackground: Colors.white,
          shadowColor: EZColors.trailblazerShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.monochrome => const ThemeColors(
          background: EZColors.monochromeBackgroundDark,
          primary: EZColors.monochromePrimaryDark,
          accent: EZColors.monochromeAccentDark,
          surface: EZColors.monochromeSurfaceDark,
          onBackground: EZColors.monochromeOnBackgroundDark,
          shadowColor: EZColors.monochromeShadowDark,
          shadowOffset: Offset(3, 3),
        ),
      AppThemeVariant.ci4Default => const ThemeColors(
          background: EZColors.ci4DefaultBackgroundDark,
          primary: EZColors.ci4DefaultPrimaryDark,
          accent: EZColors.ci4DefaultAccentDark,
          surface: EZColors.ci4DefaultSurfaceDark,
          onBackground: EZColors.ci4DefaultOnBackgroundDark,
          shadowColor: EZColors.ci4DefaultShadowDark,
          shadowOffset: Offset.zero, // Zero offset shadow for CI4
        ),
    };
  }

  /// Build light theme for a given variant.
  static ThemeData light(AppThemeVariant variant) {
    final colors = _lightColors(variant);
    final isMonochromeLike = variant == AppThemeVariant.monochrome || variant == AppThemeVariant.ci4Default;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        onSurface: colors.onBackground,
      ).copyWith(
        onPrimary: variant == AppThemeVariant.trailblazer || isMonochromeLike ? Colors.white : null,
        onSecondary: variant == AppThemeVariant.trailblazer || isMonochromeLike ? Colors.white : null,
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
          shadowOffset: colors.shadowOffset,
          secondaryButtonText: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        ),
      ],
    );
  }

  /// Build dark theme for a given variant.
  static ThemeData dark(AppThemeVariant variant) {
    final colors = _darkColors(variant);
    final isMonochromeLike = variant == AppThemeVariant.monochrome || variant == AppThemeVariant.ci4Default;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        onSurface: colors.onBackground,
      ).copyWith(
        onPrimary: variant == AppThemeVariant.trailblazer ? Colors.white : (isMonochromeLike ? const Color(0xFF111827) : null),
        onSecondary: variant == AppThemeVariant.trailblazer ? Colors.white : (isMonochromeLike ? const Color(0xFF111827) : null),
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
          shadowOffset: colors.shadowOffset,
          secondaryButtonText: variant == AppThemeVariant.trailblazer ? Colors.white : null,
        ),
      ],
    );
  }
}

