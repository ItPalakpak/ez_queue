import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ez_queue/theme/app_theme.dart';

/// Provider for theme variant state management.
final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, AppThemeVariant>((ref) {
  return ThemeVariantNotifier();
});

/// Provider for theme mode state management (light/dark/system).
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier for managing theme variant state with persistence.
class ThemeVariantNotifier extends StateNotifier<AppThemeVariant> {
  ThemeVariantNotifier() : super(AppThemeVariant.pureBold) {
    _loadSavedTheme();
  }

  /// Load saved theme variant from local storage.
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_theme_variant');
      if (saved != null) {
        final variant = AppThemeVariant.values.firstWhere(
          (v) => v.name == saved,
          orElse: () => AppThemeVariant.pureBold,
        );
        state = variant;
      }
    } catch (e) {
      // If loading fails, use default theme
      state = AppThemeVariant.pureBold;
    }
  }

  /// Set theme variant and persist to local storage.
  Future<void> setTheme(AppThemeVariant variant) async {
    state = variant;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_variant', variant.name);
    } catch (e) {
      // If saving fails, continue with state change
    }
  }
}

/// Notifier for managing theme mode state (light/dark/system) with persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  /// Load saved theme mode from local storage.
  Future<void> _loadSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_theme_mode');
      if (saved != null) {
        final mode = switch (saved) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          'system' => ThemeMode.system,
          _ => ThemeMode.system,
        };
        state = mode;
      }
    } catch (e) {
      // If loading fails, use system default
      state = ThemeMode.system;
    }
  }

  /// Set theme mode and persist to local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString('app_theme_mode', modeString);
    } catch (e) {
      // If saving fails, continue with state change
    }
  }
}

/// Provider that combines theme variant and mode to produce ThemeData.
final appThemeProvider = Provider<ThemeData>((ref) {
  final variant = ref.watch(themeVariantProvider);
  final mode = ref.watch(themeModeProvider);
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  
  // Determine if we should use dark theme
  final useDark = switch (mode) {
    ThemeMode.light => false,
    ThemeMode.dark => true,
    ThemeMode.system => brightness == Brightness.dark,
  };

  return useDark ? AppTheme.dark(variant) : AppTheme.light(variant);
});

/// Provider for current brightness based on theme mode.
final brightnessProvider = Provider<Brightness>((ref) {
  final mode = ref.watch(themeModeProvider);
  final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  
  return switch (mode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => systemBrightness,
  };
});

