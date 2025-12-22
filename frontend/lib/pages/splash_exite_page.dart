import 'package:flutter/material.dart';
import 'dart:async';
import '../app_theme.dart';
import 'package:flutter/services.dart'; // untuk keluar dari aplikasi

class ExitSplashScreen extends StatefulWidget {
  const ExitSplashScreen({super.key});

  @override
  State<ExitSplashScreen> createState() => _ExitSplashScreenState();
}

class _ExitSplashScreenState extends State<ExitSplashScreen> {
  @override
  void initState() {
    super.initState();

    // Setelah 2 detik, aplikasi akan keluar otomatis
    Timer(const Duration(seconds: 2), () {
      SystemNavigator.pop(); // keluar dari aplikasi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau ikon
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 25),
            const Text(
              'Keluar dari Banyumas SportHub...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
