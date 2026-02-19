import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:go_router/go_router.dart';

/// Theme customizer page allowing users to select theme variant and mode.
class ThemeCustomizerPage extends ConsumerWidget {
  const ThemeCustomizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVariant = ref.watch(themeVariantProvider);
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customizer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EZSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Variant Section
            Text(
              'Theme Style',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: EZSpacing.md),
            _buildThemeVariantSelector(context, ref, currentVariant),

            // Theme Mode Section (only for Pure & Bold)
            if (currentVariant == AppThemeVariant.pureBold) ...[
              const SizedBox(height: EZSpacing.xl),
              Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: EZSpacing.md),
              _buildThemeModeToggle(context, ref, currentMode),
            ],
            const SizedBox(height: EZSpacing.xxl),

            // Preview Section
            Text('Preview', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: EZSpacing.md),
            _buildThemePreview(context, ref),
          ],
        ),
      ),
    );
  }

  /// Build 3-state theme mode toggle button (Light/System/Dark).
  Widget _buildThemeModeToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    // Determine current state index (0: Light, 1: System, 2: Dark)
    int currentIndex = 0;
    if (currentMode == ThemeMode.system) {
      currentIndex = 1;
    } else if (currentMode == ThemeMode.dark) {
      currentIndex = 2;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(EZSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: _buildModeToggleSegment(
                context,
                ref,
                ThemeMode.light,
                'Light',
                Icons.light_mode,
                currentIndex == 0,
              ),
            ),
            Expanded(
              child: _buildModeToggleSegment(
                context,
                ref,
                ThemeMode.system,
                'System',
                Icons.brightness_auto,
                currentIndex == 1,
              ),
            ),
            Expanded(
              child: _buildModeToggleSegment(
                context,
                ref,
                ThemeMode.dark,
                'Dark',
                Icons.dark_mode,
                currentIndex == 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual toggle segment.
  Widget _buildModeToggleSegment(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String label,
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
          vertical: EZSpacing.md,
          horizontal: EZSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: EZSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
    ];

    return Column(
      children: variants.map((variant) {
        final (variantEnum, title, description) = variant;
        final isSelected = currentVariant == variantEnum;

        return Card(
          margin: const EdgeInsets.only(bottom: EZSpacing.sm),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : null,
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
    }
  }

  /// Build theme preview card.
  Widget _buildThemePreview(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final brightness = ref.watch(brightnessProvider);
    final currentVariant = ref.watch(themeVariantProvider);
    final isDark = brightness == Brightness.dark;
    final logoPath = _getLogoPathForVariant(currentVariant, brightness);

    return Card(
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
