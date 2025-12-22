import '../models/user.dart';
import 'api_client.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();
  final ApiClient _client = ApiClient.instance;

  /// Update user profile (name)
  Future<UserModel> updateProfile({required String name}) async {
    final response = await _client.put('/users/profile', {'name': name});
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post('/users/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  /// Get all users (admin only)
  Future<List<UserModel>> fetchUsers() async {
    final response = await _client.get('/users');
    final users = response['users'] as List<dynamic>? ?? [];
    return users
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get user by ID (admin only)
  Future<UserModel> fetchUser(String userId) async {
    final response = await _client.get('/users/$userId');
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  /// Update user role (admin only)
  Future<UserModel> updateUserRole(String userId, String role) async {
    final response = await _client.patch('/users/$userId/role', {'role': role});
    return UserModel.fromJson(response['user'] as Map<String, dynamic>);
  }

  /// Delete user (admin only)
  Future<void> deleteUser(String userId) async {
    await _client.delete('/users/$userId');
  }
}
