import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../consumer/presentation/consumer_home_screen.dart';
import '../../home_catalog/presentation/home_catalog_screen.dart';

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  bool _loading = true;
  String? _error;
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Session utilisateur introuvable.');
      }

      final data = await Supabase.instance.client
          .from('users')
          .select('roles, prenom, nom')
          .eq('auth_user_id', user.id)
          .single();

      final rawRoles = data['roles'];
      final roles = rawRoles is List
          ? rawRoles.map((role) => role.toString().toLowerCase()).toList()
          : <String>[];

      if (roles.isEmpty) {
        throw Exception('Aucun rôle associé à ce compte.');
      }

      Widget destination;

      if (roles.contains('admin')) {
        destination = AdminDashboardScreen(
          adminNom:
              '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
          adminRole: 'admin',
        );
      } else if (roles.contains('boutiquier')) {
        destination = const HomeCatalogScreen();
      } else if (roles.contains('consommateur')) {
        destination = const ConsumerHomeScreen();
      } else if (roles.contains('fournisseur')) {
        destination = const _RoleComingSoonScreen(
          role: 'Fournisseur',
        );
      } else if (roles.contains('grossiste')) {
        destination = const _RoleComingSoonScreen(
          role: 'Grossiste',
        );
      } else {
        throw Exception(
          'Rôle non pris en charge : ${roles.join(', ')}',
        );
      }

      if (!mounted) return;

      setState(() {
        _destination = destination;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _resolveRole,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _destination!;
  }
}

class _RoleComingSoonScreen extends StatelessWidget {
  final String role;

  const _RoleComingSoonScreen({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KHAYMIA'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 56,
              ),
              const SizedBox(height: 20),
              Text(
                'Espace $role',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Cet espace professionnel est en cours de préparation.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
