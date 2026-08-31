import 'package:flutter/material.dart';
import 'package:ez_queue/theme/app_theme.dart';

class EZButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isDestructive;
  final bool isSecondary;
  final double? width;
  // CHANGED: Support isLoading state with disabled interaction and spinner
  final bool isLoading;

  const EZButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.isDestructive = false,
    this.isSecondary = false,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;
    final shadowOffset = ext?.shadowOffset ?? const Offset(3, 3);
    final hasShadow = shadowOffset != Offset.zero;

    Color bg = isDestructive ? theme.colorScheme.error : theme.colorScheme.secondary;
    Color fg = isDestructive ? theme.colorScheme.onError : theme.colorScheme.onSecondary;

    if (isSecondary) {
      bg = theme.colorScheme.surface;
      fg = ext?.secondaryButtonText ?? theme.colorScheme.primary;
    }

    if (onPressed == null || isLoading) {
      bg = bg.withValues(alpha: 0.5);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: width,
            padding: padding,
            alignment: Alignment.center,
            // CHANGED: Provide IconTheme matching foreground color so icons inside EZButton automatically inherit the correct contrasting color in all themes
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : IconTheme.merge(
                    data: IconThemeData(color: fg),
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
      ),
    );
  }
}
