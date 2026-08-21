import 'package:flutter/material.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/theme/spacing.dart';

/// A reusable dialog that implements the offset shadow border design,
/// and is theme and mode aware.
class EZDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  const EZDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.padding = const EdgeInsets.all(EZSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;
    final shadowOffset = ext?.shadowOffset ?? const Offset(4, 4);
    final hasShadow = shadowOffset != Offset.zero;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: EZSpacing.lg, vertical: 24),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: shadowColor, width: 1.5),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: shadowColor,
                    offset: shadowOffset == const Offset(3, 3) ? const Offset(4, 4) : shadowOffset,
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              DefaultTextStyle(
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                child: title!,
              ),
              const SizedBox(height: EZSpacing.lg),
            ],
            Flexible(
              child: SingleChildScrollView(
                child: DefaultTextStyle(
                  style: theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
                  child: content,
                ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: EZSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
