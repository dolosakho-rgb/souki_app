import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../wallet_bnpl/presentation/wallet_screen.dart';
import '../../cart_checkout/presentation/cart_screen.dart';

class HomeCatalogScreen extends StatefulWidget {
  const HomeCatalogScreen({super.key});

  @override
  State<HomeCatalogScreen> createState() => _HomeCatalogScreenState();
}

class _HomeCatalogScreenState extends State<HomeCatalogScreen> {
  double creditDisponible = 0;
  double creditUtilise = 0;
  bool isLoadingCredit = true;
  List<Map<String, dynamic>> produits = [];
  bool isLoadingProduits = true;

  @override
  void initState() {
    super.initState();
    _loadBoutiquierData();
    _loadProduits();
  }

  Future<void> _loadBoutiquierData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('boutiquiers')
          .select('credit_disponible, credit_utilise')
          .eq('auth_user_id', userId)
          .single();
      if (mounted) {
        setState(() {
          creditDisponible = (data['credit_disponible'] as num).toDouble();
          creditUtilise = (data['credit_utilise'] as num).toDouble();
          isLoadingCredit = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCredit = false;
        });
      }
    }
  }

  Future<void> _loadProduits() async {
    try {
      final data = await Supabase.instance.client
          .from('produits')
          .select('*')
          .order('created_at');
      if (mounted) {
        setState(() {
          produits = List<Map<String, dynamic>>.from(data);
          isLoadingProduits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingProduits = false;
        });
      }
    }
  }

  Future<void> _addToCart(BuildContext context, String produitId, double prix) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final boutiquier = await Supabase.instance.client
          .from('boutiquiers')
          .select('id')
          .eq('auth_user_id', userId)
          .single();
      final boutiquierId = boutiquier['id'];

      var commande = await Supabase.instance.client
          .from('commandes')
          .select('id')
          .eq('boutiquier_id', boutiquierId)
          .eq('statut', 'brouillon')
          .maybeSingle();

      String commandeId;
      if (commande == null) {
        final nouvelleCommande = await Supabase.instance.client
            .from('commandes')
            .insert({'boutiquier_id': boutiquierId, 'statut': 'brouillon', 'total': 0})
            .select('id')
            .single();
        commandeId = nouvelleCommande['id'];
      } else {
        commandeId = commande['id'];
      }

      final ligneExistante = await Supabase.instance.client
          .from('commande_lignes')
          .select('id, quantite')
          .eq('commande_id', commandeId)
          .eq('produit_id', produitId)
          .maybeSingle();

      if (ligneExistante == null) {
        await Supabase.instance.client.from('commande_lignes').insert({
          'commande_id': commandeId,
          'produit_id': produitId,
          'quantite': 1,
          'prix_unitaire': prix,
        });
      } else {
        await Supabase.instance.client
            .from('commande_lignes')
            .update({'quantite': (ligneExistante['quantite'] as int) + 1})
            .eq('id', ligneExistante['id']);
      }

      final lignes = await Supabase.instance.client
          .from('commande_lignes')
          .select('quantite, prix_unitaire')
          .eq('commande_id', commandeId);
      double nouveauTotal = 0;
      for (final l in lignes) {
        nouveauTotal += (l['quantite'] as int) * (l['prix_unitaire'] as num).toDouble();
      }
      await Supabase.instance.client
          .from('commandes')
          .update({'total': nouveauTotal})
          .eq('id', commandeId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoute au panier'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            },
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crédit Stock Disponible (BNPL)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 4),
                        isLoadingCredit
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                                : Text('${(creditDisponible - creditUtilise).toStringAsFixed(0)} MRU', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
              children: produits.map((p) {
                return _ProductCard(
                  id: p["id"] as String,
                  name: p["nom"] as String,
                  price: "${(p["prix"] as num).toStringAsFixed(0)} MRU",
                  stock: (p["stock"] as int) > 0 ? "En stock" : "Rupture",
                  badge: "BNPL Éligible",
                  onCommander: () => _addToCart(context, p["id"] as String, (p["prix"] as num).toDouble()),
                );
              }).toList(),
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
  final String id, name, price, stock, badge;
  final VoidCallback? onCommander;
  const _ProductCard({required this.id, required this.name, required this.price, required this.stock, required this.badge, this.onCommander});

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
                Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onCommander,
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
