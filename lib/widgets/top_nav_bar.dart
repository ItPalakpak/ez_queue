import 'package:flutter/material.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:go_router/go_router.dart';

/// Reusable top navigation bar widget used across all pages.
///
/// Contains:
/// - Optional back button (left side)
/// - App logo (center-left)
/// - Home button (top-right, beside theme customizer) — optional
/// - Theme customizer button (top-right corner)
class TopNavBar extends StatelessWidget {
  /// Whether to show the back button. Defaults to true.
  final bool showBackButton;

  /// Whether to show the home button. Defaults to true.
  final bool showHomeButton;

  /// Custom back action. If null, defaults to `context.pop()`.
  final VoidCallback? onBack;

  const TopNavBar({
    super.key,
    this.showBackButton = true,
    this.showHomeButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left side: back button + logo
        Padding(
          padding: const EdgeInsets.only(left: EZSpacing.sm, top: EZSpacing.sm),
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                  IconButton(
                    onPressed: onBack ?? () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Go Back',
                  ),
                const AppLogo(height: 60, width: 60),
              ],
            ),
          ),
        ),
        // Right side: home button + theme customizer
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: EZSpacing.sm,
                right: EZSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHomeButton)
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: Icon(
                        Icons.home,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Go to Home',
                    ),
                  IconButton(
                    onPressed: () => context.push('/theme-customizer'),
                    icon: Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Theme Customizer',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
