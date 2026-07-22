import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/security/app_security.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'Smartphone 4G LTE', 'price': 4500, 'qty': 2, 'category': 'Téléphonie'},
    {'name': 'Boubou Traditionnel Homme', 'price': 1200, 'qty': 5, 'category': 'Habillement'},
  ];

  double get _totalAmount {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as int) * (item['qty'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier & Commande SOUKI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['category']} - ${item['price']} MRU x ${item['qty']}'),
                    trailing: Text(
                      '${(item['price'] as int) * (item['qty'] as int)} MRU',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Commande :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('$_totalAmount MRU', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PinVerificationDialog(
                        onAuthenticated: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Commande validée par Crédit BNPL avec succès !'), backgroundColor: Colors.green),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Valider via Crédit BNPL / Paiement Mobile', style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
