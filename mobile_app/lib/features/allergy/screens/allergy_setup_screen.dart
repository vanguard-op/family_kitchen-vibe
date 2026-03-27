import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_button.dart';
import '../cubit/allergy_cubit.dart';
import '../cubit/allergy_state.dart';

class AllergySetupScreen extends StatelessWidget {
  const AllergySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AllergyCubit>();
    return BlocListener<AllergyCubit, AllergyState>(
      listener: (context, state) {
        if (state is AllergySaved) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Allergens saved',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textPrimary)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text('Allergy Vault', style: AppTextStyles.titleLarge),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                color: AppColors.textSecondary, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.warning.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.triangleExclamation,
                        color: AppColors.warning, size: 16),
                    const Gap(AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Select all allergens for this household member',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
            Expanded(
              child: BlocBuilder<AllergyCubit, AllergyState>(
                builder: (context, state) {
                  final selected =
                      state is AllergyLoaded ? state.selected : <Allergen>[];
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSizes.sm,
                      mainAxisSpacing: AppSizes.sm,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: cubit.allAllergens.length,
                    itemBuilder: (context, index) {
                      final allergen = cubit.allAllergens[index];
                      final isSelected =
                          selected.any((a) => a.id == allergen.id);
                      return _AllergenChip(
                        allergen: allergen,
                        isSelected: isSelected,
                        onTap: () => cubit.toggle(allergen),
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, 0, AppSizes.lg, AppSizes.xl),
              child: BlocBuilder<AllergyCubit, AllergyState>(
                builder: (context, state) => PrimaryButton(
                  label: 'Save Allergens',
                  isLoading: state is AllergySaving,
                  onPressed: () => cubit.save(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergenChip extends StatelessWidget {
  final Allergen allergen;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _AllergenChip({
    required this.allergen,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.error.withAlpha(30) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.error : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: isSelected ? AppColors.error : AppColors.textSecondary,
              size: 22,
            ),
            const Gap(AppSizes.xs),
            Text(
              allergen.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.error : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 40).ms)
        .scale(duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }
}
