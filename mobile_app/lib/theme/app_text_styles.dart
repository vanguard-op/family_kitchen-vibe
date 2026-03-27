import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 57, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      );
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 45, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      );
  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      );
  static TextStyle get headlineMedium => GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      );
  static TextStyle get headlineSmall => GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      );
  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      );
  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.15,
      );
  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.1,
      );
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
      );
  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, letterSpacing: 0.25,
      );
  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.4,
      );
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.1,
      );
  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.5,
      );
  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.5,
      );
}
