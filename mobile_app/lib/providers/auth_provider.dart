import 'package:flutter/material.dart';

/// Authentication provider for managing auth state
class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _kingdomId;
  String? _role;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get kingdomId => _kingdomId;
  String? get role => _role;

  bool get isAuthenticated => _accessToken != null && _userId != null;

  /// Login user
  Future<void> login(String email, String password) async {
    try {
      // TODO: Implement login API call
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up new user
  Future<void> signup(String email, String password) async {
    try {
      // TODO: Implement signup API call
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token
  Future<void> refreshAccessToken() async {
    try {
      // TODO: Implement token refresh API call
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // TODO: Implement logout API call
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _kingdomId = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
