import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

/// Inventory provider for state management
class InventoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  DashboardModel? _dashboard;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardModel? get dashboard => _dashboard;

  /// Fetch dashboard data
  Future<void> fetchDashboard(String kingdomId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Call API client to get dashboard
      // final response = await _apiClient.getDashboard(kingdomId);
      // _dashboard = DashboardModel.fromJson(response);

      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
