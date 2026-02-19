import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/theme_customizer_button.dart';
import 'package:go_router/go_router.dart';

/// Landing page with EZQueue logo that adapts to theme mode.
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    // Select appropriate logo based on theme mode
    final logoPath = isDark
        ? 'assets/photos/logo_for_dark_mode_no_bg.png'
        : 'assets/photos/logo_for_light_mode_no_bg.png';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Main content
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(EZSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Image.asset(
                            logoPath,
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image fails to load
                              return Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    EZSpacing.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  Icons.queue,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: EZSpacing.xxl),

                          // Subtitle
                          Text(
                            'Digital Queue Ticket Generator for Clients',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: EZSpacing.xxxl),

                          // Navigation Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/department-selection');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: EZSpacing.md,
                                  horizontal: EZSpacing.lg,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    EZSpacing.radiusMd,
                                  ),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              child: Text(
                                'Get Started',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Theme customizer button at top right
          const ThemeCustomizerButton(),
        ],
      ),
    );
  }
}
