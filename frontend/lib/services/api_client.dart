import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // Default URLs for different platforms
  static const String _defaultEmulatorUrl = 'http://10.0.2.2:5000/api';
  static const String _defaultWebUrl = 'http://localhost:5000/api';

  String _baseUrl = kIsWeb ? _defaultWebUrl : _defaultEmulatorUrl;
  String? _token;
  bool _initialized = false;

  /// Get current base URL
  String get baseUrl => _baseUrl;

  /// Get current token (read-only)
  String? get token => _token;

  /// Initialize API client with saved settings
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      final savedUrl = await SettingsService.instance.getBackendUrl();
      _baseUrl = savedUrl;
      _initialized = true;
      if (kDebugMode) {
        print("[ApiClient] Initialized with baseUrl: $_baseUrl");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[ApiClient] Failed to load settings, using default: $_baseUrl");
      }
    }
  }

  /// Update base URL and save to settings
  Future<void> updateBaseUrl(String url) async {
    await SettingsService.instance.setBackendUrl(url);
    _baseUrl = await SettingsService.instance.getBackendUrl();
    if (kDebugMode) {
      print("[ApiClient] Base URL updated to: $_baseUrl");
    }
  }

  /// Reset to default URL
  Future<void> resetBaseUrl() async {
    await SettingsService.instance.resetBackendUrl();
    _baseUrl = kIsWeb ? _defaultWebUrl : _defaultEmulatorUrl;
    if (kDebugMode) {
      print("[ApiClient] Base URL reset to default: $_baseUrl");
    }
  }

  void updateToken(String? token) {
    if (kDebugMode) {
      print("[ApiClient] Token updated: ${token != null ? 'User Token Exists' : 'Null'}");
    }
    _token = token;
  }

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer ${_token!}';
      if (kDebugMode) {
        print("[ApiClient] Adding Authorization header: Bearer ${_token!.substring(0, 10)}...");
      }
    } else {
      if (kDebugMode) {
        print("[ApiClient] WARNING: No token available for request headers!");
      }
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    await init();
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) print("[ApiClient] GET $uri");
    
    final response = await http.get(uri, headers: _buildHeaders());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    await init();
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) print("[ApiClient] POST $uri");

    final response = await http.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    await init();
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) print("[ApiClient] PUT $uri");

    final response = await http.put(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    await init();
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) print("[ApiClient] PATCH $uri");

    final response = await http.patch(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    await init();
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) print("[ApiClient] DELETE $uri");

    final response = await http.delete(uri, headers: _buildHeaders());
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    if (kDebugMode) {
      print("[ApiClient] Response $status: ${response.body}");
    }

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message = 'Unknown error';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        message = decoded['message'];
      } else {
        message = response.body;
      }
    } catch (_) {
      message = response.body;
    }

    throw ApiException(message, statusCode: status);
  }

  /// Test connection to backend
  Future<bool> testConnection([String? testUrl]) async {
    try {
      final url = testUrl ?? _baseUrl;
      final healthUrl = url.replaceAll('/api', '/api/health');
      final response = await http.get(Uri.parse(healthUrl)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print("[ApiClient] Connection test failed: $e");
      }
      return false;
    }
  }
}
