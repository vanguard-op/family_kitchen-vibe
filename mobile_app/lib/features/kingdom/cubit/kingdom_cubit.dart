import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'kingdom_state.dart';

class KingdomCubit extends Cubit<KingdomState> {
  static const _uuid = Uuid();
  KingdomCubit() : super(const KingdomInitial());

  Future<void> createKingdom({
    required String name,
    required String mode,
    required String timezone,
  }) async {
    emit(const KingdomSaving());
    await Future.delayed(const Duration(milliseconds: 700));
    emit(KingdomSaved(_uuid.v4()));
  }
}
