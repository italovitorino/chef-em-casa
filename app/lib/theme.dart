import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // backgrounds
  static const Color bg = Color(0xFF15100B);
  static const Color bg2 = Color(0xFF1D160F);
  static const Color surface = Color(0xFF241B12);
  static const Color surfaceHi = Color(0xFF2C2117);

  // lines / dividers
  static const Color line = Color(0x1AF4EFE6); // rgba(244,239,230,0.10)
  static const Color line2 = Color(0x2EF4EFE6); // rgba(244,239,230,0.18)

  // text
  static const Color cream = Color(0xFFF4EFE6);
  static const Color muted = Color(0x99F4EFE6); // 0.60
  static const Color faint = Color(0x61F4EFE6); // 0.38

  // brand
  static const Color terra = Color(0xFFC8462A);
  static const Color terraDeep = Color(0xFFA5371F);
  static const Color terraSoft = Color(0x2EC8462A); // 0.18
  static const Color gold = Color(0xFFE0A458);
  static const Color goldSoft = Color(0x29E0A458); // 0.16
  static const Color green = Color(0xFF7C9A6B);
}

class AppText {
  AppText._();

  static TextStyle cormorant({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.cream,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle manrope({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.cream,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle spaceMono({
    double fontSize = 10,
    Color color = AppColors.gold,
    double? letterSpacing,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
      );
}
