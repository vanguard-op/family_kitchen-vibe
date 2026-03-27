class DashboardModel {
  final List<InventoryItem> lowStock;
  final List<InventoryItem> expiringSoon;
  final DateTime lastUpdated;

  DashboardModel({
    required this.lowStock,
    required this.expiringSoon,
    required this.lastUpdated,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      lowStock: (json['low_stock'] as List?)
          ?.map((item) => InventoryItem.fromJson(item))
          .toList() ?? [],
      expiringSoon: (json['expiring_soon'] as List?)
          ?.map((item) => InventoryItem.fromJson(item))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low_stock': lowStock.map((item) => item.toJson()).toList(),
      'expiring_soon': expiringSoon.map((item) => item.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class InventoryItem {
  final String itemId;
  final String name;
  final double quantity;
  final String unit;
  final DateTime bestBefore;
  final bool expiringSoon;
  final DateTime addedAt;

  InventoryItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.bestBefore,
    required this.expiringSoon,
    required this.addedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['item_id'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      bestBefore: DateTime.parse(json['best_before'] ?? DateTime.now().toIso8601String()),
      expiringSoon: json['expiring_soon'] ?? false,
      addedAt: DateTime.parse(json['added_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'best_before': bestBefore.toIso8601String(),
      'expiring_soon': expiringSoon,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
