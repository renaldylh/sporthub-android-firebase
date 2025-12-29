import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan dan mengambil pengaturan aplikasi
class SettingsService {
  static const String _keyBackendUrl = 'backend_url';
  
  // Default URLs based on platform
  static String get _defaultBackendUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api'; // Web/Chrome
    } else {
      return 'http://10.0.2.2:5000/api'; // Android Emulator
    }
  }

  static SettingsService? _instance;
  SharedPreferences? _prefs;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get backend URL from saved settings
  Future<String> getBackendUrl() async {
    await init();
    return _prefs?.getString(_keyBackendUrl) ?? _defaultBackendUrl;
  }

  /// Save backend URL to settings
  Future<bool> setBackendUrl(String url) async {
    await init();
    // Validate URL format
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    // Remove trailing slash
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    // Add /api if not present
    if (!url.endsWith('/api')) {
      url = '$url/api';
    }
    return await _prefs?.setString(_keyBackendUrl, url) ?? false;
  }

  /// Reset backend URL to default
  Future<bool> resetBackendUrl() async {
    await init();
    return await _prefs?.remove(_keyBackendUrl) ?? false;
  }

  /// Check if custom backend URL is set
  Future<bool> hasCustomBackendUrl() async {
    await init();
    return _prefs?.containsKey(_keyBackendUrl) ?? false;
  }
}

