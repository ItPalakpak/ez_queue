import 'package:flutter/material.dart';

/// Utility helpers for theme-aware UI components.
/// Ensures all UI components use dynamic colors that adapt to the current theme.
class ThemeHelpers {
  /// Get the appropriate text color for text on a secondary (accent) colored surface.
  /// This ensures proper contrast and readability across all themes.
  static Color getTextColorOnSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  /// Get the appropriate text color for text on a primary colored surface.
  static Color getTextColorOnPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  /// Get the appropriate text color for text on a surface.
  static Color getTextColorOnSurface(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get the appropriate text color for text on an error colored surface.
  static Color getTextColorOnError(BuildContext context) {
    return Theme.of(context).colorScheme.onError;
  }

  /// Create a ButtonStyle for ElevatedButton that uses theme-aware colors.
  /// Button text will be black in light mode and white in dark mode.
  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return ElevatedButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }

  /// Create a ButtonStyle for FilledButton that uses theme-aware colors.
  /// Button text will be black in light mode and white in dark mode.
  static ButtonStyle filledButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return FilledButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }

  /// Create a TextStyle for text on secondary (accent) colored surfaces.
  static TextStyle textStyleOnSecondary(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Create a TextStyle for text on primary colored surfaces.
  static TextStyle textStyleOnPrimary(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get button text color based on theme brightness.
  /// Returns black for light mode and white for dark mode.
  /// This ensures proper contrast for buttons with accent/secondary background.
  static Color getButtonTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  /// Create a TextStyle for button text that adapts to theme brightness.
  /// Returns black text for light mode and white text for dark mode.
  static TextStyle buttonTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: getButtonTextColor(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}

