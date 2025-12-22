import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import 'dashboard_admin_page.dart';
import 'manajemen_produk_page.dart';
import 'manajemen_pengguna_page.dart';
import 'manajemen_pesanan_page.dart';
import 'manajemen_komunitas_page.dart';
import 'manajemen_sewa_page.dart';
import 'manajemen_lapangan_page.dart';
import 'manajemen_event_page.dart';
import '../login/role_selection_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardAdminPage(),
    ManajemenProdukPage(),
    ManajemenPesananPage(),
    ManajemenLapanganPage(),
    ManajemenSewaPage(),
    ManajemenEventPage(),
    ManajemenKomunitasPage(),
    ManajemenPenggunaPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Manajemen Produk',
    'Manajemen Pesanan',
    'Manajemen Lapangan',
    'Persetujuan Sewa',
    'Manajemen Event',
    'Manajemen Komunitas',
    'Manajemen Pengguna',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin SportHub',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items - Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
                    _buildSectionLabel('Marketplace'),
                    _buildDrawerItem(Icons.shopping_bag_outlined, 'Produk', 1),
                    _buildDrawerItem(Icons.receipt_long_outlined, 'Pesanan', 2),
                    _buildSectionLabel('Sewa Lapangan'),
                    _buildDrawerItem(Icons.sports_soccer_outlined, 'Lapangan', 3),
                    _buildDrawerItem(Icons.event_available_outlined, 'Persetujuan Sewa', 4),
                    _buildSectionLabel('Lainnya'),
                    _buildDrawerItem(Icons.event, 'Event', 5),
                    _buildDrawerItem(Icons.groups_outlined, 'Komunitas', 6),
                    _buildDrawerItem(Icons.people_outline, 'Pengguna', 7),
                  ],
                ),
              ),
            ),
            // Logout Button - Fixed at bottom
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun admin?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              AuthService.instance.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const RoleSelectionPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}
