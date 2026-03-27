import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FaIconData? prefixIcon;
  final FaIconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: FaIcon(prefixIcon!,
                    size: AppSizes.iconSm, color: AppColors.textSecondary),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: FaIcon(suffixIcon!,
                      size: AppSizes.iconSm, color: AppColors.textSecondary),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: validator,
    );
  }
}
