import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _boutiquiers = [];
  String _filter = 'tous';

  @override
  void initState() {
    super.initState();
    _loadBoutiquiers();
  }

  Future<void> _loadBoutiquiers() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('boutiquiers')
          .select('id, nom, boutique_nom, telephone, statut, created_at')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _boutiquiers = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement utilisateurs: $e')),
        );
      }
    }
  }

  Future<void> _updateStatut(String boutiquierId, String nouveauStatut) async {
    try {
      await _supabase
          .from('boutiquiers')
          .update({'statut': nouveauStatut})
          .eq('id', boutiquierId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis a jour: $nouveauStatut')),
        );
      }
      _loadBoutiquiers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur mise a jour: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    if (_filter == 'tous') return _boutiquiers;
    return _boutiquiers.where((b) => b['statut'] == _filter).toList();
  }

  Color _statutColor(String? statut) {
    switch (statut) {
      case 'actif':
        return Colors.green;
      case 'en_attente':
        return Colors.orange;
      case 'bloque':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: const Color(0xFF0B3D2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoutiquiers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('tous', 'Tous'),
                  _filterChip('en_attente', 'En attente'),
                  _filterChip('actif', 'Actifs'),
                  _filterChip('bloque', 'Bloques'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredList.isEmpty
                    ? const Center(child: Text('Aucun utilisateur'))
                    : ListView.builder(
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final b = _filteredList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statutColor(b['statut']),
                                child: const Icon(Icons.storefront,
                                    color: Colors.white),
                              ),
                              title: Text(b['boutique_nom'] ?? 'Sans nom'),
                              subtitle: Text(
                                  '${b['nom'] ?? ''} - ${b['telephone'] ?? ''} - ${b['statut'] ?? 'inconnu'}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _updateStatut(b['id'], value),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                      value: 'actif',
                                      child: Text('Valider / Activer')),
                                  PopupMenuItem(
                                      value: 'bloque',
                                      child: Text('Bloquer')),
                                  PopupMenuItem(
                                      value: 'en_attente',
                                      child: Text('Remettre en attente')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}
