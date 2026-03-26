import 'package:dio/dio.dart';

/// API client for HTTP requests
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  String? _authToken;

  ApiClient({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Add auth token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_authToken != null) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }
    handler.next(options);
  }

  /// Handle errors globally
  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(e);
  }

  /// Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  /// POST /auth/signup
  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  /// POST /auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  /// POST /auth/refresh
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return response.data;
  }

  /// POST /auth/logout
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  /// GET /kingdom/{kingdom_id}/dashboard
  Future<Map<String, dynamic>> getDashboard(String kingdomId) async {
    final response = await _dio.get('/kingdom/$kingdomId/dashboard');
    return response.data;
  }

  /// GET /kingdom/{kingdom_id}/inventory
  Future<List<dynamic>> getInventory(String kingdomId, {int page = 1}) async {
    final response = await _dio.get(
      '/kingdom/$kingdomId/inventory',
      queryParameters: {'page': page},
    );
    return response.data['items'] ?? [];
  }

  /// POST /kingdom/{kingdom_id}/inventory
  Future<Map<String, dynamic>> addInventoryItem(
    String kingdomId,
    Map<String, dynamic> item,
  ) async {
    final response = await _dio.post(
      '/kingdom/$kingdomId/inventory',
      data: item,
    );
    return response.data;
  }

  /// GET /kingdom/{kingdom_id}/members
  Future<List<dynamic>> getMembers(String kingdomId) async {
    final response = await _dio.get('/kingdom/$kingdomId/members');
    return response.data['members'] ?? [];
  }

  /// POST /kingdom/{kingdom_id}/members/{member_id}/assign-role
  Future<Map<String, dynamic>> assignRole(
    String kingdomId,
    String memberId,
    String role,
  ) async {
    final response = await _dio.post(
      '/kingdom/$kingdomId/members/$memberId/assign-role',
      data: {'role': role},
    );
    return response.data;
  }
}
