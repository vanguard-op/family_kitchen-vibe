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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignupRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRoutes.kingdomSetup);
        }
      },
      child: Scaffold(
        body: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                              color: AppColors.textSecondary, size: 20),
                        ),
                      ],
                    ),
                    const Gap(AppSizes.sm),
                    Text(
                      'Create Your Kingdom',
                      style: AppTextStyles.headlineSmall,
                    ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const Gap(AppSizes.xs),
                    Text(
                      'Set up your royal kitchen',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const Gap(AppSizes.xl),
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: FontAwesomeIcons.envelope,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 200.ms)
                        .fadeIn(delay: 200.ms),
                    const Gap(AppSizes.md),
                    AppTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: FontAwesomeIcons.lock,
                      suffixIcon: _obscurePassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      onSuffixTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 8) return 'Minimum 8 characters';
                        return null;
                      },
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 280.ms)
                        .fadeIn(delay: 280.ms),
                    const Gap(AppSizes.md),
                    AppTextField(
                      controller: _confirmCtrl,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      obscureText: _obscureConfirm,
                      prefixIcon: FontAwesomeIcons.shieldHalved,
                      suffixIcon: _obscureConfirm
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      onSuffixTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v != _passwordCtrl.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 360.ms)
                        .fadeIn(delay: 360.ms),
                    const Gap(AppSizes.xl),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthFailure) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.md),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(30),
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusMd),
                                  border: Border.all(
                                      color: AppColors.error.withAlpha(80)),
                                ),
                                child: Row(
                                  children: [
                                    const FaIcon(
                                        FontAwesomeIcons.circleExclamation,
                                        color: AppColors.error,
                                        size: 16),
                                    const Gap(AppSizes.sm),
                                    Expanded(
                                      child: Text(state.message,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ).animate().shake(),
                              const Gap(AppSizes.md),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => PrimaryButton(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      ),
                    )
                        .animate()
                        .slideY(begin: 0.2, duration: 400.ms, delay: 420.ms)
                        .fadeIn(delay: 420.ms),
                    const Gap(AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: AppTextStyles.bodySmall),
                        GestureDetector(
                          onTap: () => context.goNamed(AppRoutes.login),
                          child: Text(
                            'Sign in',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                    const Gap(AppSizes.lg),
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
