import 'package:flutter/material.dart';

/// Dashboard card widget
class DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> items;
  final VoidCallback? onTap;
  final IconData? icon;

  const DashboardCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.items,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green[300]),
                const SizedBox(height: 12),
                Text(
                  'No items',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (icon != null) Icon(icon, size: 24, color: Colors.deepOrange),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              ...items.map((item) => _buildItemRow(context, item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item['name'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            item['value'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
