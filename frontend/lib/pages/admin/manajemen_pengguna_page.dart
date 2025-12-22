import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import 'detail_pengguna_page.dart';

class ManajemenPenggunaPage extends StatefulWidget {
  const ManajemenPenggunaPage({super.key});

  @override
  State<ManajemenPenggunaPage> createState() => _ManajemenPenggunaPageState();
}

class _ManajemenPenggunaPageState extends State<ManajemenPenggunaPage> {
  final UserService _userService = UserService.instance;
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.fetchUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text("Apakah Anda yakin ingin menghapus ${user.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _userService.deleteUser(user.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pengguna berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changeRole(UserModel user) {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ubah Role"),
        content: Text("Ubah role ${user.name} menjadi $newRole?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _userService.updateUserRole(user.id, newRole);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Role berhasil diubah"),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Ubah"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('Belum ada pengguna'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total: ${_users.length} pengguna",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _loadUsers,
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, index) {
                                  final user = _users[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            AppTheme.primaryColor.withOpacity(0.1),
                                        child: Icon(
                                          user.role == 'admin'
                                              ? Icons.admin_panel_settings
                                              : Icons.person,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      title: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        user.email,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Chip(
                                            label: Text(
                                              user.role.toUpperCase(),
                                              style: TextStyle(
                                                color: user.role == 'admin'
                                                    ? Colors.red
                                                    : AppTheme.primaryColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            backgroundColor: AppTheme.secondaryColor,
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'role') {
                                                _changeRole(user);
                                              } else if (value == 'delete') {
                                                _deleteUser(user);
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              const PopupMenuItem(
                                                value: 'role',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.swap_horiz, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Ubah Role'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, color: Colors.red, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPenggunaPage(
                                              nama: user.name,
                                              email: user.email,
                                              role: user.role,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
