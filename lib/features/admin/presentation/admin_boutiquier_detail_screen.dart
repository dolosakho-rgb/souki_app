import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBoutiquierDetailScreen extends StatefulWidget {
  final String boutiquierId;

  const AdminBoutiquierDetailScreen({super.key, required this.boutiquierId});

  @override
  State<AdminBoutiquierDetailScreen> createState() =>
      _AdminBoutiquierDetailScreenState();
}

class _AdminBoutiquierDetailScreenState
    extends State<AdminBoutiquierDetailScreen> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _boutiquier;
  List<Map<String, dynamic>> _commandes = [];

  int get _nbCommandes => _commandes.length;
  double get _totalCommandes =>
      _commandes.fold<double>(0, (sum, c) => sum + (c['total'] as num).toDouble());
  DateTime? get _derniereActivite =>
      _commandes.isNotEmpty ? DateTime.parse(_commandes.first['created_at']) : null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final boutiquier = await _supabase
          .from('boutiquiers')
          .select('*')
          .eq('id', widget.boutiquierId)
          .single();

      final commandes = await _supabase
          .from('commandes')
          .select('id, total, statut, created_at')
          .eq('boutiquier_id', widget.boutiquierId)
          .eq('statut', 'confirmee')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _boutiquier = boutiquier;
          _commandes = List<Map<String, dynamic>>.from(commandes);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de chargement : $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateStatut(String nouveauStatut) async {
    try {
      await _supabase
          .from('boutiquiers')
          .update({'statut': nouveauStatut})
          .eq('id', widget.boutiquierId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis a jour: $nouveauStatut')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur mise a jour: $e')),
        );
      }
    }
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B3D2E)),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche boutiquier'),
        backgroundColor: const Color(0xFF0B3D2E),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _boutiquier == null
                  ? const Center(child: Text('Boutiquier introuvable'))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _sectionCard(
                            title: 'Informations generales',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Nom', _boutiquier!['nom'] ?? '-'),
                                _infoRow('Boutique', _boutiquier!['boutique_nom'] ?? '-'),
                                _infoRow('Telephone', _boutiquier!['telephone'] ?? '-'),
                                _infoRow('Adresse', _boutiquier!['adresse'] ?? '-'),
                                _infoRow(
                                    'Date creation',
                                    _boutiquier!['created_at'] != null
                                        ? DateTime.parse(_boutiquier!['created_at'])
                                            .toString()
                                            .split(' ')
                                            .first
                                        : '-'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Statut : ',
                                        style: TextStyle(color: Colors.grey)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statutColor(_boutiquier!['statut'])
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _boutiquier!['statut'] ?? 'inconnu',
                                        style: TextStyle(
                                            color: _statutColor(_boutiquier!['statut']),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _sectionCard(
                            title: 'Activite commerciale',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Nb commandes', '$_nbCommandes'),
                                _infoRow('Total commandes',
                                    '${_totalCommandes.toStringAsFixed(0)} MRU'),
                                _infoRow(
                                    'Derniere activite',
                                    _derniereActivite != null
                                        ? _derniereActivite.toString().split(' ').first
                                        : 'Aucune'),
                                const SizedBox(height: 12),
                                if (_commandes.isEmpty)
                                  const Text('Aucune commande confirmee',
                                      style: TextStyle(color: Colors.grey))
                                else
                                  ..._commandes.take(10).map((c) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(DateTime.parse(c['created_at'])
                                                .toString()
                                                .split(' ')
                                                .first),
                                            Text(
                                                '${(c['total'] as num).toStringAsFixed(0)} MRU'),
                                          ],
                                        ),
                                      )),
                              ],
                            ),
                          ),
                          _sectionCard(
                            title: 'Finance (lecture seule)',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.lock, size: 14, color: Colors.grey),
                                    SizedBox(width: 6),
                                    Text('Donnees BNPL - non modifiables ici',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _infoRow(
                                    'Credit utilise',
                                    '${(_boutiquier!['credit_utilise'] as num).toStringAsFixed(0)} MRU'),
                                _infoRow(
                                    'Credit disponible',
                                    '${(_boutiquier!['credit_disponible'] as num).toStringAsFixed(0)} MRU'),
                              ],
                            ),
                          ),
                          _sectionCard(
                            title: 'Actions admin',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () => _updateStatut('actif'),
                                  child: const Text('Activer',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  onPressed: () => _updateStatut('en_attente'),
                                  child: const Text('Mettre en attente',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  style:
                                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => _updateStatut('bloque'),
                                  child: const Text('Bloquer',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
