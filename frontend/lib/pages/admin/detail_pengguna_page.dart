import 'package:flutter/material.dart';
import '../../app_theme.dart';

class DetailPenggunaPage extends StatelessWidget {
  final String nama;
  final String email;
  final String role;

  const DetailPenggunaPage({
    super.key,
    required this.nama,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pengguna"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.secondaryColor,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nama,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Chip(
                    label: Text(
                      role,
                      style: TextStyle(
                        color: role == "Admin"
                            ? Colors.red
                            : AppTheme.primaryColor,
                      ),
                    ),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoSection(
              title: "Informasi Akun",
              items: {
                "Status": "Aktif",
                "Tanggal Bergabung": "10 Oktober 2025",
                "Total Pesanan": "12",
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Kembali"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required Map<String, String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...items.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.grey)),
                Text(
                  entry.value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
