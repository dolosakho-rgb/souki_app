import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/security/app_security.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPaymentMethod = 'bnpl';
  String? _commandeId;
  List<Map<String, dynamic>> _lignes = [];
  double _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommande();
  }

  Future<void> _loadCommande() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final boutiquier = await Supabase.instance.client
          .from('boutiquiers')
          .select('id')
          .eq('auth_user_id', userId)
          .single();
      final boutiquierId = boutiquier['id'];
      final commande = await Supabase.instance.client
          .from('commandes')
          .select('id, total')
          .eq('boutiquier_id', boutiquierId)
          .eq('statut', 'brouillon')
          .maybeSingle();
      if (commande == null) {
        if (mounted) setState(() { _commandeId = null; _lignes = []; _total = 0; _loading = false; });
        return;
      }
      final lignes = await Supabase.instance.client
          .from('commande_lignes')
          .select('id, quantite, prix_unitaire, produits(nom)')
          .eq('commande_id', commande['id']);
      double total = 0;
      for (final l in lignes) {
        total += (l['quantite'] as int) * (l['prix_unitaire'] as num).toDouble();
      }
      if (mounted) {
        setState(() {
          _commandeId = commande['id'];
          _lignes = List<Map<String, dynamic>>.from(lignes);
          _total = total;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur chargement panier: ' + e.toString())));
      }
    }
  }

  void _processCheckout(BuildContext context) {
    if (_selectedPaymentMethod == 'bnpl') {
      // Exiger le code PIN sécurisé pour le crédit BNPL
      showDialog(
        context: context,
        builder: (context) => PinVerificationDialog(
          onAuthenticated: () {
            _showSuccessDialog(context, 'Commande validée par Crédit Stock (BNPL) sécurisé !');
          },
        ),
      );
    } else {
      _showSuccessDialog(context, 'Commande enregistrée en mode Cash à la livraison.');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Succès 🎉'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier & Tunnel de Commande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Articles sélectionnés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.inventory_2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sac de Riz (25kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Quantité : 2', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text('1 700 MRU', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Mode de Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('Crédit Stock (BNPL)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Sécurisé par code PIN SOUKI Pay'),
            value: 'bnpl',
            groupValue: _selectedPaymentMethod,
            activeColor: AppColors.primary,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Paiement Cash / Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Payer à la réception de la livraison'),
            value: 'cash',
            groupValue: _selectedPaymentMethod,
            activeColor: AppColors.primary,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total à régler', style: TextStyle(color: AppColors.textMuted)),
                      Text(_total.toStringAsFixed(0) + ' MRU', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _processCheckout(context),
                      child: const Text('Valider la commande'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
