import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatelessWidget {

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 10), () {
      print('Auth check timeout, navigating to login');
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.hasKingdom) {
            context.goNamed(AppRoutes.home);
          } else {
            context.goNamed(AppRoutes.kingdomSetup);
          }
        } else if (state is AuthUnauthenticated) {
          context.goNamed(AppRoutes.login);
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
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
                      size: 40,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const Gap(24),
                Text(
                  'The Royal Hearth',
                  style: AppTextStyles.headlineMedium,
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms)
                    .fadeIn(duration: 500.ms, delay: 300.ms),
                const Gap(8),
                Text(
                  'Family Kitchen',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 450.ms)
                    .fadeIn(duration: 500.ms, delay: 450.ms),
                const Gap(64),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
