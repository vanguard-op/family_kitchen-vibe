import 'package:equatable/equatable.dart';

class Allergen extends Equatable {
  final String id;
  final String name;
  final String icon;
  const Allergen({required this.id, required this.name, required this.icon});
  @override List<Object?> get props => [id, name, icon];
}

abstract class AllergyState extends Equatable {
  const AllergyState();
  @override List<Object?> get props => [];
}
class AllergyInitial extends AllergyState { const AllergyInitial(); }
class AllergyLoaded extends AllergyState {
  final List<Allergen> selected;
  const AllergyLoaded(this.selected);
  @override List<Object?> get props => [selected];
}
class AllergySaving extends AllergyState { const AllergySaving(); }
class AllergySaved extends AllergyState { const AllergySaved(); }
