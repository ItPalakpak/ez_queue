import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable theme customizer button widget.
/// Positions itself at the top right corner of the screen with minimal padding.
/// Can be used across multiple pages for consistent theme customization access.
class ThemeCustomizerButton extends StatelessWidget {
  const ThemeCustomizerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            right: 8.0,
          ),
          child: IconButton(
            onPressed: () {
              context.push('/theme-customizer');
            },
            icon: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Theme Customizer',
          ),
        ),
      ),
    );
  }
}
