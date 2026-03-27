import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/loaders/shimmer_card.dart';
import '../cubit/members_cubit.dart';
import '../cubit/members_state.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MembersCubit>().loadMembers();
  }

  void _showInviteDialog() {
    final emailCtrl = TextEditingController();
    MemberRole selectedRole = MemberRole.guest;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSizes.lg,
            right: AppSizes.lg,
            top: AppSizes.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Invite to Kingdom', style: AppTextStyles.titleLarge),
              const Gap(AppSizes.md),
              TextField(
                controller: emailCtrl,
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const Gap(AppSizes.md),
              DropdownButtonFormField<MemberRole>(
                value: selectedRole,
                dropdownColor: AppColors.surfaceAlt,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(labelText: 'Role'),
                items: MemberRole.values
                    .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedRole = v);
                },
              ),
              const Gap(AppSizes.lg),
              ElevatedButton(
                onPressed: () {
                  if (emailCtrl.text.isNotEmpty) {
                    context
                        .read<MembersCubit>()
                        .inviteMember(emailCtrl.text.trim(), selectedRole);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Send Invite'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Court Members', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.userPlus,
                color: AppColors.primary, size: 18),
            onPressed: _showInviteDialog,
          ),
          const Gap(AppSizes.sm),
        ],
      ),
      body: BlocBuilder<MembersCubit, MembersState>(
        builder: (context, state) {
          if (state is MembersLoading) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: ShimmerList(count: 3, itemHeight: 72),
            );
          }
          if (state is MembersLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.lg),
              itemCount: state.members.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.divider, height: 1),
              itemBuilder: (context, index) {
                final member = state.members[index];
                return _MemberTile(member: member, index: index);
              },
            );
          }
          if (state is MembersFailure) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final KingdomMember member;
  final int index;

  const _MemberTile({required this.member, required this.index});

  static const _roleColors = {
    MemberRole.king: AppColors.primary,
    MemberRole.queen: AppColors.accent,
    MemberRole.chef: AppColors.info,
    MemberRole.prince: AppColors.success,
    MemberRole.princess: Color(0xFFE91E63),
    MemberRole.guest: AppColors.textDisabled,
  };

  @override
  Widget build(BuildContext context) {
    final color = _roleColors[member.role] ?? AppColors.textSecondary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color.withAlpha(40),
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          style: AppTextStyles.titleMedium.copyWith(color: color),
        ),
      ),
      title: Row(
        children: [
          Text(member.name, style: AppTextStyles.titleSmall),
          if (member.isAdmin) ...[
            const Gap(AppSizes.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
              ),
              child: Text('Admin',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ],
      ),
      subtitle: Text(member.email, style: AppTextStyles.bodySmall),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm, vertical: AppSizes.xs),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(member.role.label,
            style: AppTextStyles.labelSmall.copyWith(color: color)),
      ),
    )
        .animate(delay: (index * 60).ms)
        .slideX(begin: 0.1)
        .fadeIn(duration: 300.ms);
  }
}
