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
import '../../../widgets/inputs/app_text_field.dart';
import '../../../router/app_routes.dart';
import '../cubit/kingdom_cubit.dart';
import '../cubit/kingdom_state.dart';

class KingdomSetupScreen extends StatefulWidget {
  const KingdomSetupScreen({super.key});

  @override
  State<KingdomSetupScreen> createState() => _KingdomSetupScreenState();
}

class _KingdomSetupScreenState extends State<KingdomSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _mode = 'solo';
  String _timezone = 'UTC';

  static const _timezones = [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Australia/Sydney',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<KingdomCubit>().createKingdom(
          name: _nameCtrl.text.trim(),
          mode: _mode,
          timezone: _timezone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KingdomCubit, KingdomState>(
      listener: (context, state) {
        if (state is KingdomSaved) {
          context.goNamed(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(AppSizes.xl),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withAlpha(80), width: 2),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.crown,
                              color: AppColors.primary, size: 32),
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.elasticOut),
                    ),
                    const Gap(AppSizes.lg),
                    Text('Your Kingdom Awaits',
                            style: AppTextStyles.headlineSmall,
                            textAlign: TextAlign.center)
                        .animate()
                        .slideY(begin: 0.2, duration: 400.ms, delay: 150.ms)
                        .fadeIn(delay: 150.ms),
                    const Gap(AppSizes.xs),
                    Text('Set up your royal household',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 250.ms),
                    const Gap(AppSizes.xl),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Kingdom Name',
                      hint: 'e.g. The Smith Household',
                      prefixIcon: FontAwesomeIcons.houseFire,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name required'
                          : null,
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms)
                        .fadeIn(delay: 300.ms),
                    const Gap(AppSizes.lg),
                    Text('Household Mode', style: AppTextStyles.titleSmall)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 380.ms),
                    const Gap(AppSizes.sm),
                    Row(
                      children: [
                        _ModeChip(
                          label: 'Solo',
                          icon: FontAwesomeIcons.user,
                          selected: _mode == 'solo',
                          onTap: () => setState(() => _mode = 'solo'),
                        ),
                        const Gap(AppSizes.sm),
                        _ModeChip(
                          label: 'Family',
                          icon: FontAwesomeIcons.peopleRoof,
                          selected: _mode == 'family',
                          onTap: () => setState(() => _mode = 'family'),
                        ),
                        const Gap(AppSizes.sm),
                        _ModeChip(
                          label: 'Shared',
                          icon: FontAwesomeIcons.houseMedical,
                          selected: _mode == 'shared',
                          onTap: () => setState(() => _mode = 'shared'),
                        ),
                      ],
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 400.ms)
                        .fadeIn(delay: 400.ms),
                    const Gap(AppSizes.lg),
                    DropdownButtonFormField<String>(
                      value: _timezone,
                      dropdownColor: AppColors.card,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(labelText: 'Timezone'),
                      items: _timezones
                          .map((tz) =>
                              DropdownMenuItem(value: tz, child: Text(tz)))
                          .toList(),
                      onChanged: (v) => setState(() => _timezone = v!),
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 480.ms)
                        .fadeIn(delay: 480.ms),
                    const Gap(AppSizes.xl),
                    BlocBuilder<KingdomCubit, KingdomState>(
                      builder: (context, state) => PrimaryButton(
                        label: 'Establish Kingdom',
                        isLoading: state is KingdomSaving,
                        onPressed: _submit,
                        icon: FontAwesomeIcons.crown,
                      ),
                    )
                        .animate()
                        .slideY(begin: 0.2, duration: 400.ms, delay: 550.ms)
                        .fadeIn(delay: 550.ms),
                    const Gap(AppSizes.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              vertical: AppSizes.md, horizontal: AppSizes.sm),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withAlpha(30)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              FaIcon(icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 18),
              const Gap(AppSizes.xs),
              Text(label,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
