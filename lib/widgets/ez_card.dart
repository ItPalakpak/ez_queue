import 'package:flutter/material.dart';
import 'package:ez_queue/theme/app_theme.dart';

class EZCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const EZCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;
    final shadowOffset = ext?.shadowOffset ?? const Offset(3, 3);
    final hasShadow = shadowOffset != Offset.zero;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: shadowColor, width: 1.5),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
