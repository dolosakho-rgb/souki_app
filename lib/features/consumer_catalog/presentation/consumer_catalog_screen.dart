import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsumerCatalogScreen extends StatefulWidget {
  const ConsumerCatalogScreen({super.key});

  @override
  State<ConsumerCatalogScreen> createState() =>
      _ConsumerCatalogScreenState();
}

class _ConsumerCatalogScreenState
    extends State<ConsumerCatalogScreen> {

  List<dynamic> produits = [];
  bool loading = true;
  String? error;


  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }


  Future<void> _loadCatalog() async {
    try {

      final data = await Supabase.instance.client
          .from('consumer_marketplace_catalog')
          .select();

      setState(() {
        produits = data;
        loading = false;
      });

    } catch (e) {

      setState(() {
        error = e.toString();
        loading = false;
      });

    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Catalogue KHAYMIA'),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : error != null

              ? Center(
                  child: Text(error!),
                )

              : ListView.builder(

                  itemCount: produits.length,

                  itemBuilder: (context, index) {

                    final produit = produits[index];

                    return Card(

                      child: ListTile(

                        title: Text(
                          produit['produit_nom'] ?? '',
                        ),

                        subtitle: Text(
                          '${produit['prix_vente']} MRU',
                        ),

                        trailing: Text(
                          produit['boutique_nom'] ?? '',
                        ),

                      ),

                    );

                  },

                ),
    );
  }
}
