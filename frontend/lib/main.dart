import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'pages/splash_screen.dart';
import 'pages/splash_exite_page.dart';
import 'pages/user/user_main_page.dart';
import 'pages/admin/admin_main_page.dart';
import 'pages/login/role_selection_page.dart';
import 'pages/user/marketplace/cart_provider.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()), 
      ],
      child: const BanyumasSportHubApp(),
    ),
  );
}

class BanyumasSportHubApp extends StatelessWidget {
  const BanyumasSportHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banyumas SportHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), 
      routes: {
        '/role-selection': (context) => const RoleSelectionPage(),
        '/user': (context) => const UserMainPage(),
        '/admin': (context) => const AdminMainPage(),
        '/exit': (context) => const ExitSplashScreen(), 
      },
    );
  }
}
