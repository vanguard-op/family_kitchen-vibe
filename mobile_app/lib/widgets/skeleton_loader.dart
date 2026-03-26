import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading widget with shimmer animation
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Card skeleton loader
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets padding;

  const SkeletonCard({
    Key? key,
    this.height = 120,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      child: Card(
        child: Column(
          children: [
            SkeletonLoader(width: double.infinity, height: height * 0.6),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 200, height: 12),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: 150, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
