import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DetailPesananPage extends StatelessWidget {
  final String pesananId;
  const DetailPesananPage({super.key, required this.pesananId});

  @override
  Widget build(BuildContext context) {
    // Dummy data contoh
    final Map<String, dynamic> pesanan = {
      "id": pesananId,
      "nama": "Andi Pratama",
      "tanggal": "20 Oktober 2025",
      "status": "Selesai",
      "alamat": "Jl. Soedirman No. 45, Banyumas",
      "total": "Rp 450.000",
      "items": [
        {"nama": "Sepatu Futsal Nike", "jumlah": 1, "harga": "Rp 450.000"},
      ],
    };

    // Pastikan items bertipe List<Map<String, dynamic>>
    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(pesanan["items"] as List);

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Pesanan ${pesanan['id']}"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle("Informasi Pelanggan"),
            _buildInfoRow("Nama", pesanan["nama"]),
            _buildInfoRow("Tanggal", pesanan["tanggal"]),
            _buildInfoRow("Alamat", pesanan["alamat"]),
            const SizedBox(height: 20),

            _buildSectionTitle("Daftar Produk"),
            ...items.map((item) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined,
                        color: AppTheme.primaryColor),
                    title: Text(
                      item["nama"].toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      "Jumlah: ${item["jumlah"]}",
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                    trailing: Text(
                      item["harga"].toString(),
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            _buildSectionTitle("Ringkasan"),
            _buildInfoRow("Status", pesanan["status"]),
            _buildInfoRow("Total Pembayaran", pesanan["total"], isBold: true),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Kembali"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
