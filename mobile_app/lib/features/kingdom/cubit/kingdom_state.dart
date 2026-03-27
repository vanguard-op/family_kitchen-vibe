import 'package:equatable/equatable.dart';

abstract class KingdomState extends Equatable {
  const KingdomState();
  @override
  List<Object?> get props => [];
}
class KingdomInitial extends KingdomState { const KingdomInitial(); }
class KingdomSaving extends KingdomState { const KingdomSaving(); }
class KingdomSaved extends KingdomState {
  final String kingdomId;
  const KingdomSaved(this.kingdomId);
  @override List<Object?> get props => [kingdomId];
}
class KingdomFailure extends KingdomState {
  final String message;
  const KingdomFailure(this.message);
  @override List<Object?> get props => [message];
}
