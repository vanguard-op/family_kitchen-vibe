import 'package:flutter/material.dart';

/// API client for HTTP requests
class ApiClient {
  final String baseUrl;
  final String? authToken;

  ApiClient({
    required this.baseUrl,
    this.authToken,
  });

  /// Login request
  Future<Map<String, dynamic>> login(String email, String password) async {
    // TODO: Implement login API call
    throw UnimplementedError();
  }

  /// Signup request
  Future<Map<String, dynamic>> signup(String email, String password) async {
    // TODO: Implement signup API call
    throw UnimplementedError();
  }

  /// Get dashboard data
  Future<Map<String, dynamic>> getDashboard(String kingdomId) async {
    // TODO: Implement dashboard API call
    throw UnimplementedError();
  }

  /// Get inventory list
  Future<List<dynamic>> getInventory(String kingdomId, {int page = 1}) async {
    // TODO: Implement get inventory API call
    throw UnimplementedError();
  }
}
