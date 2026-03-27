import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Brand: Warm-Dark "Royal Hearth" palette ---
  static const primary     = Color(0xFFD4880E); // Amber gold — primary action
  static const primaryDark = Color(0xFFA36806); // Darker amber
  static const accent      = Color(0xFFE8631A); // Warm copper — secondary highlight

  // --- Surfaces ---
  static const surface    = Color(0xFF1A1210); // Near-black warm background
  static const surfaceAlt = Color(0xFF231916); // Slightly lighter warm dark
  static const card       = Color(0xFF2D201C); // Card background

  // --- Neutral ---
  static const textPrimary   = Color(0xFFF5E6D3); // Warm off-white
  static const textSecondary = Color(0xFFC4A882); // Muted warm tan
  static const textDisabled  = Color(0xFF7A6355); // Disabled text

  // --- Semantic ---
  static const success = Color(0xFF4CAF50);
  static const error   = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);
  static const info    = Color(0xFF2196F3);

  // --- Divider / Border ---
  static const divider = Color(0xFF3D2B24);
  static const border  = Color(0xFF4A352C);

  // --- Gradient stops ---
  static const gradientTop    = Color(0xFF2D1B14);
  static const gradientBottom = Color(0xFF0F0A08);
}
