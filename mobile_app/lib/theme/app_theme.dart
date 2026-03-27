import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_sizes.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.surface,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          onSecondary: AppColors.surface,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        cardColor: AppColors.card,
        dividerColor: AppColors.divider,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: AppSizes.elevationNone,
          titleTextStyle: AppTextStyles.titleLarge,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: AppSizes.elevationNone,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            textStyle: AppTextStyles.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            minimumSize: const Size.fromHeight(52),
            elevation: AppSizes.elevationNone,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.md),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceAlt,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textDisabled,
          selectedLabelStyle: AppTextStyles.labelSmall,
          unselectedLabelStyle: AppTextStyles.labelSmall,
          type: BottomNavigationBarType.fixed,
          elevation: AppSizes.elevationNone,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceAlt,
          labelStyle: AppTextStyles.labelMedium,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        ),
      );
}
