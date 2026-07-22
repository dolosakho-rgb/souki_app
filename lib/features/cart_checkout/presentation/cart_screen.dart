import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPaymentMethod = 'bnpl'; // 'bnpl' ou 'cash'

  void _validateOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Commande Validée !'),
        content: Text(
          _selectedPaymentMethod == 'bnpl'
              ? 'Votre commande a été imputée sur votre Crédit Stock (BNPL). Livraison prévue sous 24h.'
              : 'Commande enregistrée en mode Cash à la livraison.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Panier & Tunnel de Commande', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Articles sélectionnés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          
          // Article simulé dans le panier
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
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
                const Text('1 700 MRU', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Choix du mode de paiement
          const Text('Mode de Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          
          RadioListTile<String>(
            title: const Text('Crédit Stock (BNPL)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Utiliser votre plafond de crédit SOUKI'),
            value: 'bnpl',
            groupValue: _selectedPaymentMethod,
            activeColor: AppColors.primary,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Paiement Cash / Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Payer à la livraison'),
            value: 'cash',
            groupValue: _selectedPaymentMethod,
            activeColor: AppColors.primary,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
          ),
          const SizedBox(height: 32),

          // Total et bouton de validation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total à régler', style: TextStyle(color: AppColors.textMuted)),
                    Text('1 700 MRU', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _validateOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Valider la commande', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
