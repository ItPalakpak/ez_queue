import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/theme/spacing.dart';

/// Reusable app logo widget that adapts to theme variant and mode.
/// Can be used across multiple pages for consistent branding.
class AppLogo extends ConsumerWidget {
  /// Height of the logo. Defaults to 80.
  final double height;

  /// Width of the logo. Defaults to 80.
  final double width;

  const AppLogo({
    super.key,
    this.height = 80,
    this.width = 80,
  });

  /// Get logo path based on theme variant.
  String _getLogoPathForVariant(
    AppThemeVariant variant,
    Brightness brightness,
  ) {
    switch (variant) {
      case AppThemeVariant.pureBold:
        // Pure & Bold uses brightness-based logo
        return brightness == Brightness.dark
            ? 'assets/photos/logo_for_dark_mode_no_bg.png'
            : 'assets/photos/logo_for_light_mode_no_bg.png';
      case AppThemeVariant.techy:
        // Modern/Techy uses dark logo
        return 'assets/photos/logo_for_dark_mode_no_bg.png';
      case AppThemeVariant.friendly:
        // Friendly/Human uses light logo
        return 'assets/photos/logo_for_light_mode_no_bg.png';
      case AppThemeVariant.corporate:
        // Corporate/Minimal uses light logo
        return 'assets/photos/logo_for_light_mode_no_bg.png';
      case AppThemeVariant.playful:
        // Playful uses dark logo
        return 'assets/photos/logo_for_dark_mode_no_bg.png';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);
    final currentVariant = ref.watch(themeVariantProvider);
    final logoPath = _getLogoPathForVariant(currentVariant, brightness);

    return Image.asset(
      logoPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
          ),
          child: Icon(
            Icons.queue,
            size: height * 0.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

