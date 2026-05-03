import 'package:flutter/material.dart';
import 'package:ez_queue/theme/app_theme.dart';

class EZButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isDestructive;
  final bool isSecondary;
  final double? width;

  const EZButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.isDestructive = false,
    this.isSecondary = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;

    Color bg = isDestructive ? theme.colorScheme.error : theme.colorScheme.secondary;
    Color fg = isDestructive ? theme.colorScheme.onError : theme.colorScheme.onSecondary;

    if (isSecondary) {
      bg = theme.colorScheme.surface;
      fg = ext?.secondaryButtonText ?? theme.colorScheme.primary;
    }

    if (onPressed == null) {
      bg = bg.withValues(alpha: 0.5);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: shadowColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: width,
            padding: padding,
            alignment: Alignment.center,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ) ?? TextStyle(color: fg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
