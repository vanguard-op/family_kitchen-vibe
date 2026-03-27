import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_button.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../cubit/inventory_cubit.dart';
import '../cubit/inventory_state.dart';

class InventoryAddScreen extends StatefulWidget {
  const InventoryAddScreen({super.key});

  @override
  State<InventoryAddScreen> createState() => _InventoryAddScreenState();
}

class _InventoryAddScreenState extends State<InventoryAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  String _category = 'Produce';
  String _unit = 'kg';
  DateTime? _expiryDate;

  static const _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Seafood',
    'Grains',
    'Pantry',
    'Frozen',
    'Beverages',
    'Condiments',
    'Other',
  ];
  static const _units = ['kg', 'g', 'L', 'mL', 'pcs', 'pack', 'can', 'bottle'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
                surface: AppColors.card,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<InventoryCubit>().addItem(
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: double.tryParse(_quantityCtrl.text) ?? 1.0,
          unit: _unit,
          expiryDate: _expiryDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryCubit, InventoryState>(
      listener: (context, state) {
        if (state is InventoryItemSaved) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Item added to pantry',
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
          title: Text('Add Item', style: AppTextStyles.titleLarge),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                color: AppColors.textSecondary, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Item Name',
                  hint: 'e.g. Chicken Breast',
                  prefixIcon: FontAwesomeIcons.drumstickBite,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name required' : null,
                ).animate().slideX(begin: -0.1, duration: 400.ms).fadeIn(),
                const Gap(AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: _quantityCtrl,
                        label: 'Quantity',
                        hint: '1.0',
                        keyboardType: TextInputType.number,
                        prefixIcon: FontAwesomeIcons.hashtag,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const Gap(AppSizes.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _unit,
                        dropdownColor: AppColors.card,
                        style: AppTextStyles.bodyMedium,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: _units
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => _unit = v!),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 400.ms, delay: 80.ms)
                    .fadeIn(delay: 80.ms),
                const Gap(AppSizes.md),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: AppColors.card,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 400.ms, delay: 160.ms)
                    .fadeIn(delay: 160.ms),
                const Gap(AppSizes.md),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.calendarDays,
                            color: AppColors.textSecondary,
                            size: AppSizes.iconSm),
                        const Gap(AppSizes.md),
                        Text(
                          _expiryDate != null
                              ? 'Expires ${DateFormat('MMM d, yyyy').format(_expiryDate!)}'
                              : 'Set Expiry Date (optional)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _expiryDate != null
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                          ),
                        ),
                        const Spacer(),
                        if (_expiryDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _expiryDate = null),
                            child: const FaIcon(FontAwesomeIcons.xmark,
                                color: AppColors.textSecondary, size: 14),
                          ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 400.ms, delay: 240.ms)
                    .fadeIn(delay: 240.ms),
                const Gap(AppSizes.xl),
                BlocBuilder<InventoryCubit, InventoryState>(
                  builder: (context, state) => PrimaryButton(
                    label: 'Add to Pantry',
                    isLoading: state is InventoryItemSaving,
                    onPressed: _submit,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.2, duration: 400.ms, delay: 320.ms)
                    .fadeIn(delay: 320.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
