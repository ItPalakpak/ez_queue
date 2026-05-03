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
      foregroundColor: brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
  }

  /// Create a ButtonStyle for FilledButton that uses theme-aware colors.
  /// Button text will be black in light mode and white in dark mode.
  static ButtonStyle filledButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return FilledButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
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

  /// Create an InputDecoration for dropdown fields with enhanced visuals.
  /// Uses Roboto font and provides consistent styling across the app.
  static InputDecoration dropdownInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      // CHANGED: suppress inline error text — errors are shown below the field
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        color: Colors.grey,
      ),
    );
  }

  /// Create a generic InputDecoration for text fields with enhanced visuals.
  /// Pass [maxLength] and [currentLength] to show an inline character counter
  /// on the same line as the input (as a suffix), instead of Flutter's default
  /// below-field counter.
  static InputDecoration textInputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    EdgeInsetsGeometry? contentPadding,
    int? maxLength,
    int? currentLength,
    Widget? extraSuffix,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,

      // Suppress Flutter's default below-field counter entirely.
      counterText: '',

      // Render the count inline on the right side of the input row.
      suffixIcon: (maxLength != null || extraSuffix != null)
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (maxLength != null)
                    Text(
                      '${currentLength ?? 0}/$maxLength',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  if (maxLength != null && extraSuffix != null)
                    const SizedBox(width: 8),
                  if (extraSuffix != null) extraSuffix,
                ],
              ),
            )
          : null,

      // CHANGED: suppress inline error text — errors are shown below the field
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        color: Colors.grey,
      ),
    );
  }
}
