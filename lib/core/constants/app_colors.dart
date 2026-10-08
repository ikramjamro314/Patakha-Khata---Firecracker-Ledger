import 'package:flutter/material.dart';

/// All colors extracted from Figma — never use raw Color values elsewhere.
abstract final class AppColors {
  // Brand / primary
  static const Color primary = Color(0xFFA43700);
  static const Color primaryDark = Color(0xFF802A00);
  static const Color primaryDeep = Color(0xFFCD4700);
  static const Color splashOrange = Color(0xFFE65100);

  // Accent
  static const Color amber = Color(0xFFFEB300);
  static const Color amberText = Color(0xFF6A4800);
  static const Color amberDark = Color(0xFF7E5700);

  // Backgrounds
  static const Color backgroundCream = Color(0xFFFFFBF5);
  static const Color backgroundSurface = Color(0xFFFEF7FF);
  static const Color surfaceLavender = Color(0xFFF3EBF7);
  static const Color cardLavender = Color(0xFFF9F1FD);
  static const Color inputFill = Color(0xFFF3EBF7);

  // Text
  static const Color textPrimary = Color(0xFF1D1A22);
  static const Color textSecondary = Color(0xFF5A4138);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFBFF);

  // Borders
  static const Color border = Color(0xFFE3BFB2);
  static const Color borderInput = Color(0xFF8F7066);
  static const Color borderLight = Color(0x33E3BFB2);

  // Status
  static const Color paidGreen = Color(0xFFA3F69C);
  static const Color paidGreenText = Color(0xFF002204);
  static const Color unpaidPink = Color(0xFFFFDAD6);
  static const Color unpaidRed = Color(0xFF93000A);
  static const Color stockGreen = Color(0xFF186A22);
  static const Color tierGreen = Color(0xFF358438);
  static const Color tierGreenText = Color(0xFFF7FFF1);

  // Avatars / chips
  static const Color avatarPeach = Color(0xFFFFDBCF);
  static const Color avatarTan = Color(0xFFFFDEAC);
  static const Color avatarTanText = Color(0xFF604100);
  static const Color imagePlaceholder = Color(0xFFE7E0EB);

  // Receipt
  static const Color receiptTotalBg = Color(0xFFFFDBCF);
  static const Color paidStamp = Color(0xFF186A22);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    colors: [splashOrange, splashOrange],
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDeep, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient scaffoldGradient = LinearGradient(
    colors: [backgroundCream, backgroundCream],
  );
}
