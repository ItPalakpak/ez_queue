import 'package:flutter/material.dart';
import 'package:ez_queue/theme/app_theme.dart';

class EZInputField extends StatelessWidget {
  final Widget child;

  // CHANGED: optional border color override (used for error state visual feedback)
  final Color? borderColor;

  // CHANGED: added isRequired to show a red asterisk on top right
  final bool isRequired;

  const EZInputField({
    super.key,
    required this.child,
    this.borderColor,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;

    final container = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor ?? shadowColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (!isRequired) return container;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        container,
        const Positioned(
          top: 12,
          right: 12,
          child: Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
