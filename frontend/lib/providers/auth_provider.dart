import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService.instance;

  UserModel? currentUser;
  bool isLoading = false;
  String? error;

  Future<void> bootstrap() async {
    try {
      currentUser = await _service.fetchProfile();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool adminOnly = false,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = await _service.login(email: email, password: password);
      if (adminOnly && user.role != 'admin') {
        _service.logout();
        currentUser = null;
        error = 'Akun ini bukan admin';
        return false;
      }
      currentUser = user;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      currentUser = await _service.register(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _service.logout();
    currentUser = null;
    notifyListeners();
  }
}
