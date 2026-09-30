import 'package:flutter/material.dart';

/// Visual tokens for the Profile feature.
///
/// Deliberately NOT a new design language: every value here is taken
/// directly from the tokens already used across Home / Sign In / Sign Up /
/// Reset Password, so Profile reads as part of the same application.
abstract final class ProfileTokens {
  // Flat page background — same as Home's `_pageBg`. Intentionally NOT
  // `AuthPageBackground` (the decorative blurred-circles/dot-grid
  // background): that treatment fits a marketing-style entry page, not a
  // page whose job is calm, readable account information.
  static const Color pageBg = Color(0xFFF4F7FB);

  // Same tone as the Sign In / Reset Password AppBar — blends into the
  // page instead of a hard, differently-colored strip.
  static const Color appBarBg = Color(0xFFEFF3FA);

  static const Color primaryBlue = Color(0xFF2A6FDB);
  static const Color darkNavy = Color(0xFF16213E);
  static const Color mutedText = Color(0xFF5A6A85);
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFDDE3EC);
  static const Color chipBg = Color(0xFFE8F0FE);
  static const Color chipBorder = Color(0xFFADC8FF);
  static const Color dangerRed = Color(0xFFE0483E);

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static BoxDecoration card() => BoxDecoration(
    color: cardBg,
    borderRadius: cardRadius,
    border: Border.all(color: cardBorder),
    boxShadow: cardShadow,
  );
}
