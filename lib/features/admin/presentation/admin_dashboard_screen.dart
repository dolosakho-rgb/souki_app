import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminNom;
  final String adminRole;

  const AdminDashboardScreen({
    super.key,
    required this.adminNom,
    required this.adminRole,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  int _nbBoutiques = 0;
  int _nbCommandes = 0;
  double _volumeVentes = 0;
  double _creditDisponibleTotal = 0;
  double _creditUtiliseTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final boutiquiers = await _supabase
          .from('boutiquiers')
          .select('credit_disponible, credit_utilise');

      final commandes = await _supabase
          .from('commandes')
          .select('total');

      final nbBoutiques = boutiquiers.length;
      final creditDisponibleTotal = boutiquiers.fold<double>(
          0, (sum, b) => sum + (b['credit_disponible'] as num).toDouble());
      final creditUtiliseTotal = boutiquiers.fold<double>(
          0, (sum, b) => sum + (b['credit_utilise'] as num).toDouble());

      final nbCommandes = commandes.length;
      final volumeVentes = commandes.fold<double>(
          0, (sum, c) => sum + (c['total'] as num).toDouble());

      setState(() {
        _nbBoutiques = nbBoutiques;
        _nbCommandes = nbCommandes;
        _volumeVentes = volumeVentes;
        _creditDisponibleTotal = creditDisponibleTotal;
        _creditUtiliseTotal = creditUtiliseTotal;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement : $e';
        _loading = false;
      });
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF0B3D2E)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin KHAYMIA'),
        backgroundColor: const Color(0xFF0B3D2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Icon(Icons.admin_panel_settings,
                          size: 64, color: Color(0xFF0B3D2E)),
                      const SizedBox(height: 16),
                      Text(
                        'Bienvenue, ${widget.adminNom}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rôle : ${widget.adminRole}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _buildStatCard(
                          'Boutiques', '$_nbBoutiques', Icons.storefront),
                      const SizedBox(height: 12),
                      _buildStatCard(
                          'Commandes', '$_nbCommandes', Icons.receipt_long),
                      const SizedBox(height: 12),
                      _buildStatCard(
                          'Volume des ventes',
                          '${_volumeVentes.toStringAsFixed(0)} MRU',
                          Icons.trending_up),
                      const SizedBox(height: 12),
                      _buildStatCard(
                          'Crédit disponible total',
                          '${_creditDisponibleTotal.toStringAsFixed(0)} MRU',
                          Icons.account_balance_wallet),
                      const SizedBox(height: 12),
                      _buildStatCard(
                          'Crédit utilisé total',
                          '${_creditUtiliseTotal.toStringAsFixed(0)} MRU',
                          Icons.credit_card),
                    ],
                  ),
                ),
    );
  }
}
