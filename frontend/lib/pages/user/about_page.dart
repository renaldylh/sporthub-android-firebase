import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 🏀 Logo / Icon aplikasi
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Banyumas SportHub",
              style: TextStyle(
                fontSize: 24,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Versi 1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            // 🧩 Deskripsi aplikasi
            const Text(
              "Banyumas SportHub adalah aplikasi yang dirancang untuk menghubungkan masyarakat Banyumas dengan berbagai fasilitas olahraga yang tersedia. "
              "Pengguna dapat memesan lapangan, mengikuti event olahraga, bergabung dalam komunitas, serta membaca artikel seputar dunia olahraga secara mudah.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),

            // 💬 Tim & kontak
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Dikembangkan oleh",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tim Mahasiswa ABP Banyumas Tech.\nProyek ini bertujuan mendigitalisasi ekosistem olahraga di Kabupaten Banyumas.",
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Hubungi Kami:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("📧 banyumassporthub@gmail.com"),
                    Text("🌐 www.banyumassporthub.id"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔙 Tombol kembali
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              label: const Text(
                "Kembali",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
