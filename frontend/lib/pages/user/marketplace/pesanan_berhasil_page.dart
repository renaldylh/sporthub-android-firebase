import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../user_main_page.dart';

class PesananBerhasilPage extends StatelessWidget {
  const PesananBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: AppTheme.primaryColor, size: 120),
              const SizedBox(height: 20),
              const Text(
                "Pesanan Berhasil 🎉",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 10),
              const Text(
                "Terima kasih telah berbelanja di Banyumas SportHub!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserMainPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
