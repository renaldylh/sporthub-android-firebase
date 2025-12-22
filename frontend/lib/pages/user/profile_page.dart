import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../login/role_selection_page.dart';
import 'marketplace/pesanan_saya_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header profil
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.name ?? "Guest",
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (user?.role == 'admin')
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Menu pengaturan profil
            _buildProfileOption(
              icon: Icons.person_outline_rounded,
              title: "Edit Profil",
              onTap: () => _showEditProfileDialog(context),
            ),
            _buildProfileOption(
              icon: Icons.lock_outline_rounded,
              title: "Ubah Kata Sandi",
              onTap: () => _showChangePasswordDialog(context),
            ),
            _buildProfileOption(
              icon: Icons.history_rounded,
              title: "Riwayat Pemesanan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PesananSayaPage()),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifikasi",
              onTap: () => _showNotificationsDialog(context),
            ),
            _buildProfileOption(
              icon: Icons.help_outline_rounded,
              title: "Pusat Bantuan",
              onTap: () => _showHelpCenterDialog(context),
            ),
            _buildProfileOption(
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 30),

            // Tombol logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = _authService.currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profil"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nama", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await UserService.instance.updateProfile(name: nameController.text);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil berhasil diupdate"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ubah Kata Sandi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password Lama", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password Baru", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Konfirmasi Password", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password tidak cocok"), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await UserService.instance.changePassword(
                  currentPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password berhasil diubah"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text("Notifikasi"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem(
                icon: Icons.local_shipping,
                title: "Pesanan Dikirim",
                message: "Pesanan Anda sedang dalam perjalanan",
                time: "2 jam yang lalu",
                isNew: true,
              ),
              _buildNotificationItem(
                icon: Icons.check_circle,
                title: "Pembayaran Dikonfirmasi",
                message: "Admin telah mengkonfirmasi pembayaran Anda",
                time: "5 jam yang lalu",
                isNew: false,
              ),
              _buildNotificationItem(
                icon: Icons.event,
                title: "Event Baru",
                message: "Ada event olahraga baru di Banyumas!",
                time: "1 hari yang lalu",
                isNew: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNew ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text("Baru", style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
                Text(message, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pusat Bantuan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
              title: const Text("Hubungi Kami"),
              subtitle: const Text("+62 812-3456-7890"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text("Email"),
              subtitle: const Text("support@banyumassport.com"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
              title: const Text("Alamat"),
              subtitle: const Text("Jl. Olahraga No. 123, Banyumas"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.question_answer, color: AppTheme.primaryColor),
              title: const Text("FAQ"),
              subtitle: const Text("Pertanyaan yang sering diajukan"),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tentang Aplikasi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_soccer, size: 48, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Banyumas SportHub",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(child: Text("Versi 1.0.0", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            const Text(
              "Aplikasi olahraga terlengkap di Banyumas untuk:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem("Sewa lapangan olahraga"),
            _buildFeatureItem("Belanja peralatan olahraga"),
            _buildFeatureItem("Ikut event olahraga"),
            _buildFeatureItem("Bergabung komunitas olahraga"),
            const SizedBox(height: 16),
            const Text("© 2024 Banyumas SportHub", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
