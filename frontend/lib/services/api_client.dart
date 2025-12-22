import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static const String _defaultUrl = kIsWeb 
      ? 'http://localhost:5000/api' 
      : 'http://10.0.2.2:5000/api';

  final String baseUrl =
      const String.fromEnvironment('API_BASE_URL', defaultValue: _defaultUrl);

  String? _token;

  /// Get current token (read-only)
  String? get token => _token;

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
    final uri = Uri.parse('$baseUrl$path');
    if (kDebugMode) print("[ApiClient] GET $uri");
    
    final response = await http.get(uri, headers: _buildHeaders());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    if (kDebugMode) print("[ApiClient] POST $uri");

    final response = await http.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    if (kDebugMode) print("[ApiClient] PUT $uri");

    final response = await http.put(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    if (kDebugMode) print("[ApiClient] PATCH $uri");

    final response = await http.patch(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
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
}
