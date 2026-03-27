import 'package:flutter_bloc/flutter_bloc.dart';
import 'allergy_state.dart';

const _commonAllergens = [
  Allergen(id: 'gluten',       name: 'Gluten',       icon: 'wheat_slab'),
  Allergen(id: 'dairy',        name: 'Dairy',         icon: 'cow'),
  Allergen(id: 'eggs',         name: 'Eggs',          icon: 'egg'),
  Allergen(id: 'nuts',         name: 'Tree Nuts',     icon: 'acorn'),
  Allergen(id: 'peanuts',      name: 'Peanuts',       icon: 'seedling'),
  Allergen(id: 'shellfish',    name: 'Shellfish',     icon: 'shrimp'),
  Allergen(id: 'fish',         name: 'Fish',          icon: 'fish'),
  Allergen(id: 'soy',          name: 'Soy',           icon: 'leaf'),
  Allergen(id: 'sesame',       name: 'Sesame',        icon: 'circle-dot'),
  Allergen(id: 'sulfites',     name: 'Sulfites',      icon: 'wine-bottle'),
];

class AllergyCubit extends Cubit<AllergyState> {
  AllergyCubit() : super(const AllergyLoaded([]));

  void toggle(Allergen allergen) {
    final current = state;
    if (current is! AllergyLoaded) return;
    final selected = List<Allergen>.from(current.selected);
    if (selected.any((a) => a.id == allergen.id)) {
      selected.removeWhere((a) => a.id == allergen.id);
    } else {
      selected.add(allergen);
    }
    emit(AllergyLoaded(selected));
  }

  Future<void> save() async {
    emit(const AllergySaving());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const AllergySaved());
  }

  List<Allergen> get allAllergens => _commonAllergens;
}
