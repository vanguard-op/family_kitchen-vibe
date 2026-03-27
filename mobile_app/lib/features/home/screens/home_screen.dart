import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/loaders/shimmer_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../../router/app_routes.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.lg),
            sliver: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      const ShimmerCard(height: 80),
                      const Gap(AppSizes.md),
                      const ShimmerCard(height: 80),
                      const Gap(AppSizes.md),
                      const ShimmerCard(height: 160),
                    ]),
                  );
                }
                if (state is HomeLoaded) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _ChefModeToggle(
                        active: state.summary.chefModeActive,
                        onToggle: context.read<HomeCubit>().toggleChefMode,
                      )
                          .animate()
                          .slideY(begin: -0.1, duration: 400.ms)
                          .fadeIn(),
                      const Gap(AppSizes.lg),
                      Text('Quick Access', style: AppTextStyles.titleMedium)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms),
                      const Gap(AppSizes.sm),
                      _DashboardGrid(summary: state.summary),
                      const Gap(AppSizes.lg),
                      if (state.summary.expiringCount > 0)
                        _ExpiryAlert(count: state.summary.expiringCount)
                            .animate()
                            .slideY(begin: 0.1, duration: 400.ms, delay: 400.ms)
                            .fadeIn(delay: 400.ms),
                    ]),
                  );
                }
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Something went wrong',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      snap: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.crown,
                  color: AppColors.primary, size: 16),
            ),
          ),
          const Gap(AppSizes.sm),
          Text('The Royal Hearth', style: AppTextStyles.titleMedium),
        ],
      ),
      actions: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.rightFromBracket,
              color: AppColors.textSecondary, size: 18),
          onPressed: () => _confirmLogout(context),
        ),
        const Gap(AppSizes.xs),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Leave the Kingdom?', style: AppTextStyles.titleMedium),
        content: Text('You will need to sign in again.',
            style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.goNamed(AppRoutes.login);
            },
            child: Text('Sign Out',
                style:
                    AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ChefModeToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onToggle;

  const _ChefModeToggle({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [
                    AppColors.primary.withAlpha(50),
                    AppColors.accent.withAlpha(30),
                  ]
                : [AppColors.card, AppColors.surfaceAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.utensils,
              color: active ? AppColors.primary : AppColors.textSecondary,
              size: AppSizes.iconLg,
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chef Mode',
                      style: AppTextStyles.titleSmall.copyWith(
                        color:
                            active ? AppColors.primary : AppColors.textPrimary,
                      )),
                  Text(
                    active
                        ? 'Cooking workflow active'
                        : 'Tap to enter cooking mode',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: active,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceAlt,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final DashboardSummary summary;

  const _DashboardGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        label: 'Pantry',
        value: summary.inventoryCount.toString(),
        subtitle: 'items',
        icon: FontAwesomeIcons.bowlRice,
        color: AppColors.primary,
        route: AppRoutes.inventory,
      ),
      _CardData(
        label: 'Members',
        value: summary.memberCount.toString(),
        subtitle: 'in kingdom',
        icon: FontAwesomeIcons.peopleRoof,
        color: AppColors.info,
        route: AppRoutes.members,
      ),
      _CardData(
        label: 'Allergens',
        value: '−',
        subtitle: 'manage',
        icon: FontAwesomeIcons.shieldVirus,
        color: AppColors.error,
        route: AppRoutes.allergySetup,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.sm,
      mainAxisSpacing: AppSizes.sm,
      childAspectRatio: 0.85,
      children: cards.asMap().entries.map((entry) {
        final card = entry.value;
        return _DashboardCard(data: card, index: entry.key);
      }).toList(),
    );
  }
}

class _CardData {
  final String label;
  final String value;
  final String subtitle;
  final FaIconData icon;
  final Color color;
  final String route;

  const _CardData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _DashboardCard extends StatelessWidget {
  final _CardData data;
  final int index;

  const _DashboardCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(data.route),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Center(
                child: FaIcon(data.icon, color: data.color, size: 16),
              ),
            ),
            const Spacer(),
            Text(data.value,
                style: AppTextStyles.headlineSmall.copyWith(color: data.color)),
            Text(data.label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    )
        .animate(delay: (100 + index * 80).ms)
        .scale(duration: 350.ms, curve: Curves.easeOut)
        .fadeIn(duration: 350.ms);
  }
}

class _ExpiryAlert extends StatelessWidget {
  final int count;

  const _ExpiryAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.triangleExclamation,
              color: AppColors.warning, size: 20),
          const Gap(AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count item${count > 1 ? "s" : ""} expiring soon',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.warning)),
                Text('Check your pantry', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.inventory),
            child: Text('View',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }
}
