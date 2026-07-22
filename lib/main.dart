import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const SoukiApp());
}

class SoukiApp extends StatelessWidget {
  const SoukiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOUKI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
