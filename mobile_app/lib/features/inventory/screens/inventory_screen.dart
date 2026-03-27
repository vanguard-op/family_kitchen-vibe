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
import '../../../router/app_routes.dart';
import '../cubit/inventory_cubit.dart';
import '../cubit/inventory_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().loadItems();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Pantry', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus,
                color: AppColors.primary, size: 20),
            onPressed: () => context.pushNamed(AppRoutes.inventoryAdd),
          ),
          const Gap(AppSizes.sm),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.lg, AppSizes.sm, AppSizes.lg, AppSizes.md),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMedium,
              onChanged: (q) => context.read<InventoryCubit>().search(q),
              decoration: InputDecoration(
                hintText: 'Search pantry...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                      color: AppColors.textSecondary, size: AppSizes.iconSm),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    child: ShimmerList(count: 5, itemHeight: 72),
                  );
                }
                if (state is InventoryLoaded) {
                  final items = state.filtered;
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(FontAwesomeIcons.boxOpen,
                              color: AppColors.textDisabled, size: 48),
                          const Gap(AppSizes.md),
                          Text('Your pantry is empty',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.textSecondary)),
                          const Gap(AppSizes.sm),
                          Text('Tap + to add your first item',
                              style: AppTextStyles.bodySmall),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg, 0, AppSizes.lg, AppSizes.xxl),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.divider, height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _InventoryTile(item: item, index: index);
                    },
                  );
                }
                if (state is InventoryFailure) {
                  return Center(
                    child: Text(state.message,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final InventoryItem item;
  final int index;

  const _InventoryTile({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.textSecondary;
    FaIconData statusIcon = FontAwesomeIcons.circleCheck;
    if (item.isExpired) {
      statusColor = AppColors.error;
      statusIcon = FontAwesomeIcons.circleXmark;
    } else if (item.isExpiringSoon) {
      statusColor = AppColors.warning;
      statusIcon = FontAwesomeIcons.triangleExclamation;
    }

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: AppSizes.xs),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Center(
          child: FaIcon(FontAwesomeIcons.bowlRice,
              color: AppColors.primary, size: AppSizes.iconSm),
        ),
      ),
      title: Text(item.name, style: AppTextStyles.titleSmall),
      subtitle: Text(
        '${item.quantity} ${item.unit} • ${item.category}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: FaIcon(statusIcon, color: statusColor, size: 16),
    )
        .animate(delay: (index * 50).ms)
        .slideX(begin: 0.1)
        .fadeIn(duration: 300.ms);
  }
}
