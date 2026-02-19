import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for EZQueue.
/// Uses Inter as primary font and JetBrains Mono for queue numbers.
class EZTypography {
  /// Main text theme using Inter font.
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );

  /// Queue number display style using JetBrains Mono.
  static TextStyle get queueNumber => GoogleFonts.jetBrainsMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
      );

  /// Ticket code style using JetBrains Mono.
  static TextStyle get ticketCode => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w400,
      );
}

