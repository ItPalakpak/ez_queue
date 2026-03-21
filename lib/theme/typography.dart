import 'package:flutter/material.dart';

/// Typography system for EZQueue.
/// Uses Roboto as primary font and JetBrains Mono for queue numbers.
class EZTypography {
  /// Main text theme using Roboto font.
  static TextTheme get textTheme => TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  /// Queue number display style using JetBrains Mono.
  static TextStyle get queueNumber => TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 48,
    fontWeight: FontWeight.w700,
  );

  /// Ticket code style using JetBrains Mono.
  static TextStyle get ticketCode => TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );
}
