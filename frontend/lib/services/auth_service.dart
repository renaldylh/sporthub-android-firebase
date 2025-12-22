import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banyumas_sport_hub/models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _client = ApiClient.instance;
  UserModel? currentUser;

  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.role == 'admin';

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (kDebugMode) print("[AuthService] Token saved to SharedPreferences");
      _client.updateToken(token);
    } catch (e) {
      if (kDebugMode) print("[AuthService] Error saving token: $e");
    }
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _client.updateToken(null);
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('auth_token')) {
        if (kDebugMode) print("[AuthService] No token found in SharedPreferences");
        return false;
      }

      final token = prefs.getString('auth_token');
      if (token == null) return false;

      if (kDebugMode) print("[AuthService] Token found, attempting restore...");
      _client.updateToken(token);

      final user = await fetchProfile();
      if (user != null) {
        if (kDebugMode) print("[AuthService] Auto login successful for ${user.email}");
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("[AuthService] Auto login failed: $e");
    }
    return false;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token']?.toString();
    
    currentUser = user;
    if (token != null) {
      await _saveToken(token);
    }
    
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token']?.toString();
    
    currentUser = user;
    if (token != null) {
      await _saveToken(token);
    }

    return user;
  }

  Future<UserModel?> fetchProfile() async {
    try {
      final response = await _client.get('/auth/profile');
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      currentUser = user;
      return user;
    } catch (e) {
      if (kDebugMode) print("[AuthService] Fetch profile failed: $e");
      return null;
    }
  }

  Future<void> logout() async {
    currentUser = null;
    await _removeToken();
  }
}
