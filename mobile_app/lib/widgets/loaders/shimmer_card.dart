import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const ShimmerCard({
    super.key,
    this.height = 100,
    this.width,
    this.radius = AppSizes.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.card,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const ShimmerList({super.key, this.count = 4, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}
