import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_card.dart';

/// Theme customizer page allowing users to select theme variant and mode.
class ThemeCustomizerPage extends ConsumerWidget {
  const ThemeCustomizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVariant = ref.watch(themeVariantProvider);
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          const TopNavBar(showHomeButton: true),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title and Theme Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Theme Customizer',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (currentVariant == AppThemeVariant.pureBold)
                        _buildSmallThemeModeToggle(context, ref, currentMode),
                    ],
                  ),
                  const SizedBox(height: EZSpacing.xl),

                  // Theme Variant Section
                  Text(
                    'Theme Style',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  _buildThemeVariantSelector(context, ref, currentVariant),
                  const SizedBox(height: EZSpacing.xxl),

                  // Preview Section
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  _buildThemePreview(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact 3-state theme mode toggle button (Light/System/Dark).
  Widget _buildSmallThemeModeToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSmallSegment(
            context,
            ref,
            ThemeMode.light,
            Icons.light_mode,
            currentMode == ThemeMode.light,
          ),
          _buildSmallSegment(
            context,
            ref,
            ThemeMode.system,
            Icons.brightness_auto,
            currentMode == ThemeMode.system,
          ),
          _buildSmallSegment(
            context,
            ref,
            ThemeMode.dark,
            Icons.dark_mode,
            currentMode == ThemeMode.dark,
          ),
        ],
      ),
    );
  }

  /// Build individual compact toggle segment.
  Widget _buildSmallSegment(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Build theme variant selector.
  Widget _buildThemeVariantSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeVariant currentVariant,
  ) {
    final variants = [
      (AppThemeVariant.pureBold, 'Pure & Bold', 'Universal theme'),
      (AppThemeVariant.techy, 'Modern / Techy', 'Geometric, dark, futuristic'),
      (AppThemeVariant.friendly, 'Friendly / Human', 'Warm, approachable'),
      (AppThemeVariant.corporate, 'Corporate / Minimal', 'Clean, professional'),
      (AppThemeVariant.playful, 'Playful', 'Bold, energetic'),
      (AppThemeVariant.trailblazer, 'Trailblazer', 'Navy, gold, elegant'),
    ];

    return Column(
      children: variants.map((variant) {
        final (variantEnum, title, description) = variant;
        final isSelected = currentVariant == variantEnum;

        return Padding(
          padding: const EdgeInsets.only(bottom: EZSpacing.md),
          child: EZCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text(title),
              subtitle: Text(description),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : null,
              onTap: () {
                ref.read(themeVariantProvider.notifier).setTheme(variantEnum);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

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
      case AppThemeVariant.trailblazer:
        // Trailblazer uses dark logo
        return 'assets/photos/logo_for_dark_mode_no_bg.png';
    }
  }

  /// Build theme preview card.
  Widget _buildThemePreview(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final brightness = ref.watch(brightnessProvider);
    final currentVariant = ref.watch(themeVariantProvider);
    final isDark = brightness == Brightness.dark;
    final logoPath = _getLogoPathForVariant(currentVariant, brightness);

    return EZCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(EZSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo preview
            Center(
              child: Image.asset(
                logoPath,
                height: 100,
                width: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.queue,
                    size: 60,
                    color: theme.colorScheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: EZSpacing.lg),

            // Color preview
            Text(
              'EZQueue',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: EZSpacing.sm),
            Text(
              'Preview of your selected theme',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: EZSpacing.md),

            // Accent color preview
            Container(
              padding: const EdgeInsets.all(EZSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
              ),
              child: Text(
                'Accent Color',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
