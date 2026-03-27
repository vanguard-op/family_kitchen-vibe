import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeLoading());

  Future<void> loadDashboard() async {
    emit(const HomeLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    emit(const HomeLoaded(DashboardSummary(
      inventoryCount: 24,
      expiringCount: 3,
      memberCount: 2,
    )));
  }

  void toggleChefMode() {
    final current = state;
    if (current is! HomeLoaded) return;
    emit(HomeLoaded(
        current.summary.copyWith(chefModeActive: !current.summary.chefModeActive)));
  }
}
