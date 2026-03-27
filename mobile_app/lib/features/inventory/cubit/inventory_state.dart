import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    return expiryDate!.difference(DateTime.now()).inDays <= 3;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [id, name, category, quantity, unit, expiryDate];
}

abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  final String searchQuery;

  const InventoryLoaded({required this.items, this.searchQuery = ''});

  List<InventoryItem> get filtered {
    if (searchQuery.isEmpty) return items;
    final q = searchQuery.toLowerCase();
    return items.where((i) => i.name.toLowerCase().contains(q) || i.category.toLowerCase().contains(q)).toList();
  }

  @override
  List<Object?> get props => [items, searchQuery];
}

class InventoryFailure extends InventoryState {
  final String message;
  const InventoryFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class InventoryItemSaving extends InventoryState {
  const InventoryItemSaving();
}

class InventoryItemSaved extends InventoryState {
  const InventoryItemSaved();
}
