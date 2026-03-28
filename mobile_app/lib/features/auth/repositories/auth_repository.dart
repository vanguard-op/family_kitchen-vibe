import 'package:dio/dio.dart';
import 'package:family_kitchen/utils/exceptions.dart';
import 'package:family_kitchen/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';

class AuthRepository {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';
  static const _hasKingdomKey = 'has_kingdom';

  final Dio _dio;

  AuthRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.apiV1,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              validateStatus: ApiConfig.validateStatus,
            ));

  Future<({String userId, String email, bool hasKingdom})> login(
      String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });
      final token = response.data['access_token'] as String;
      final userId = response.data['user_id'] as String? ?? '';
      final hasKingdom = response.data['has_kingdom'] as bool? ?? false;
      await _persist(
          token: token, userId: userId, email: email, hasKingdom: hasKingdom);
      return (userId: userId, email: email, hasKingdom: hasKingdom);
    } on DioException catch (e) {
      throw e.toAppException();
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  Future<({String userId, String email, bool hasKingdom})> signup(
      String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'] as String;
      final userId = response.data['user_id'] as String? ?? '';
      await _persist(
          token: token, userId: userId, email: email, hasKingdom: false);
      return (userId: userId, email: email, hasKingdom: false);
    } on DioException catch (e) {
      throw e.toAppException();
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  Future<({String userId, String email, bool hasKingdom})?> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    final userId = prefs.getString(_userIdKey) ?? '';
    final email = prefs.getString(_emailKey) ?? '';
    final hasKingdom = prefs.getBool(_hasKingdomKey) ?? false;
    return (userId: userId, email: email, hasKingdom: hasKingdom);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_hasKingdomKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _persist({
    required String token,
    required String userId,
    required String email,
    required bool hasKingdom,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    await prefs.setBool(_hasKingdomKey, hasKingdom);
  }
}
