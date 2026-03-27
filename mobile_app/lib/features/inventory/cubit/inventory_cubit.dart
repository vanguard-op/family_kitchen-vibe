import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  static const _uuid = Uuid();
  final List<InventoryItem> _items = [];

  InventoryCubit() : super(const InventoryInitial());

  Future<void> loadItems() async {
    emit(const InventoryLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(InventoryLoaded(items: List.from(_items)));
  }

  void search(String query) {
    final current = state;
    if (current is InventoryLoaded) {
      emit(InventoryLoaded(items: current.items, searchQuery: query));
    }
  }

  Future<void> addItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    emit(const InventoryItemSaving());
    await Future.delayed(const Duration(milliseconds: 400));
    _items.add(InventoryItem(
      id: _uuid.v4(),
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
    ));
    emit(const InventoryItemSaved());
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    emit(InventoryLoaded(items: List.from(_items)));
  }
}
