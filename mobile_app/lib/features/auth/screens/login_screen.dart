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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.hasKingdom) {
            context.goNamed(AppRoutes.home);
          } else {
            context.goNamed(AppRoutes.kingdomSetup);
          }
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
                    const Gap(AppSizes.xxl),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(80),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.utensils,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.elasticOut),
                    ),
                    const Gap(AppSizes.lg),
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .slideY(begin: 0.2, duration: 400.ms, delay: 150.ms)
                        .fadeIn(delay: 150.ms),
                    const Gap(AppSizes.xs),
                    Text(
                      'Sign in to your kingdom',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
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
                        .slideX(begin: -0.1, duration: 400.ms, delay: 300.ms)
                        .fadeIn(delay: 300.ms),
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
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    )
                        .animate()
                        .slideX(begin: -0.1, duration: 400.ms, delay: 380.ms)
                        .fadeIn(delay: 380.ms),
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
                        label: 'Sign In',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      ),
                    )
                        .animate()
                        .slideY(begin: 0.2, duration: 400.ms, delay: 450.ms)
                        .fadeIn(delay: 450.ms),
                    const Gap(AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: AppTextStyles.bodySmall),
                        GestureDetector(
                          onTap: () => context.goNamed(AppRoutes.signup),
                          child: Text(
                            'Create one',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 550.ms),
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
