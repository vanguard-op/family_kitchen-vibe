import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int inventoryCount;
  final int expiringCount;
  final int memberCount;
  final bool chefModeActive;

  const DashboardSummary({
    this.inventoryCount = 0,
    this.expiringCount = 0,
    this.memberCount = 1,
    this.chefModeActive = false,
  });

  DashboardSummary copyWith({
    int? inventoryCount,
    int? expiringCount,
    int? memberCount,
    bool? chefModeActive,
  }) => DashboardSummary(
    inventoryCount: inventoryCount ?? this.inventoryCount,
    expiringCount: expiringCount ?? this.expiringCount,
    memberCount: memberCount ?? this.memberCount,
    chefModeActive: chefModeActive ?? this.chefModeActive,
  );

  @override
  List<Object?> get props =>
      [inventoryCount, expiringCount, memberCount, chefModeActive];
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}
class HomeLoading extends HomeState { const HomeLoading(); }
class HomeLoaded extends HomeState {
  final DashboardSummary summary;
  const HomeLoaded(this.summary);
  @override List<Object?> get props => [summary];
}
class HomeFailure extends HomeState {
  final String message;
  const HomeFailure(this.message);
  @override List<Object?> get props => [message];
}
