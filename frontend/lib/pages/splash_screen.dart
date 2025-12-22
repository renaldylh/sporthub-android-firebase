import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../app_theme.dart';
import 'login/role_selection_page.dart';
import 'user/user_main_page.dart';
import 'admin/admin_main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Tunggu sedikit agar animasi splash terlihat
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await AuthService.instance.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      if (AuthService.instance.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserMainPage()),
        );
      }
    } else {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 25),
            const Text(
              "Banyumas SportHub",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
