import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../wallet_bnpl/presentation/wallet_screen.dart';

class HomeCatalogScreen extends StatelessWidget {
  const HomeCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutique El Baraka', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Nouakchott, Mauritanie', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crédit Stock Disponible (BNPL)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 4),
                        Text('15 000 MRU', style: TextStyle(fontSize: 22, fontWeight: FontWeight.extrabold, color: AppColors.textDark)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                      child: const Text('Gérer', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Catégories FMCG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CategoryChip(label: 'Tous', isSelected: true),
                  _CategoryChip(label: 'Riz & Céréales'),
                  _CategoryChip(label: 'Huile & Sucre'),
                  _CategoryChip(label: 'Boissons'),
                  _CategoryChip(label: 'Laiterie'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Produits Populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _ProductCard(name: 'Sac de Riz (25kg)', price: '850 MRU', stock: 'En stock', badge: 'BNPL Éligible'),
                _ProductCard(name: 'Bidon d\'Huile 5L', price: '420 MRU', stock: 'En stock', badge: 'BNPL Éligible'),
                _ProductCard(name: 'Carton Lait Gloria', price: '1 200 MRU', stock: 'Stock Limité', badge: 'BNPL Éligible'),
                _ProductCard(name: 'Sac de Sucre (50kg)', price: '1 600 MRU', stock: 'En stock', badge: 'BNPL Éligible'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name, price, stock, badge;
  const _ProductCard({required this.name, required this.price, required this.stock, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(child: Icon(Icons.inventory_2, size: 48, color: AppColors.primary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.extrabold, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.zero),
                    child: const Text('Commander', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
