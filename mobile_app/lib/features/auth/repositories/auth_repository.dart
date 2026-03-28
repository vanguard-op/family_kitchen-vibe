import 'package:dio/dio.dart';
import 'package:family_kitchen/utils/exceptions.dart';
import 'package:family_kitchen/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

  /// Extract user information from OIDC id_token
  /// 
  /// The id_token contains user identity:
  /// {user_id, email, kingdom_id, role}
  Map<String, dynamic> _extractUserFromIdToken(String idToken) {
    try {
      final decodedToken = JwtDecoder.decode(idToken);
      return {
        'user_id': decodedToken['user_id'] as String? ?? '',
        'email': decodedToken['email'] as String? ?? '',
        'kingdom_id': decodedToken['kingdom_id'] as String? ?? 'default-kingdom',
        'role': decodedToken['role'] as String? ?? 'user',
      };
    } catch (e) {
      throw AppException('Failed to decode id_token: $e');
    }
  }

  Future<({String userId, String email, bool hasKingdom})> login(
      String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // Extract tokens from OIDC response
      final accessToken = response.data['access_token'] as String? ?? '';
      final idToken = response.data['id_token'] as String? ?? '';
      
      if (accessToken.isEmpty || idToken.isEmpty) {
        throw AppException('Invalid authentication response: missing tokens');
      }
      
      // Decode id_token to extract user information
      final userInfo = _extractUserFromIdToken(idToken);
      final userId = userInfo['user_id'] as String;
      final userEmail = userInfo['email'] as String;
      final kingdomId = userInfo['kingdom_id'] as String;
      final hasKingdom = kingdomId != 'default-kingdom';
      
      await _persist(
        token: accessToken,
        userId: userId,
        email: userEmail,
        hasKingdom: hasKingdom,
      );
      
      return (userId: userId, email: userEmail, hasKingdom: hasKingdom);
    } on DioException catch (e) {
      throw e.toAppException();
    } catch (e) {
      throw AppException('Login failed: $e');
    }
  }

  Future<({String userId, String email, bool hasKingdom})> signup(
      String email, String password) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
      });
      
      // Extract tokens from OIDC response
      final accessToken = response.data['access_token'] as String? ?? '';
      final idToken = response.data['id_token'] as String? ?? '';
      
      if (accessToken.isEmpty || idToken.isEmpty) {
        throw AppException('Invalid authentication response: missing tokens');
      }
      
      // Decode id_token to extract user information
      final userInfo = _extractUserFromIdToken(idToken);
      final userId = userInfo['user_id'] as String;
      final userEmail = userInfo['email'] as String;
      final kingdomId = userInfo['kingdom_id'] as String;
      final hasKingdom = kingdomId != 'default-kingdom';
      
      await _persist(
        token: accessToken,
        userId: userId,
        email: userEmail,
        hasKingdom: hasKingdom,
      );
      
      return (userId: userId, email: userEmail, hasKingdom: hasKingdom);
    } on DioException catch (e) {
      throw e.toAppException();
    } catch (e) {
      throw AppException('Signup failed: $e');
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
