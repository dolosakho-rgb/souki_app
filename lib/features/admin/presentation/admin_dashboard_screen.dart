import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String adminNom;
  final String adminRole;

  const AdminDashboardScreen({
    super.key,
    required this.adminNom,
    required this.adminRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration KHAYMIA'),
        backgroundColor: const Color(0xFF0B3D2E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 64, color: Color(0xFF0B3D2E)),
            const SizedBox(height: 16),
            Text('Bienvenue, $adminNom', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Rôle : $adminRole', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
