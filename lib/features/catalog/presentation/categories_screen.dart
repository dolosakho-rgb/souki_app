import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Téléphonie & High-Tech', 'icon': Icons.phone_android, 'color': Colors.blue},
    {'name': 'Électroménager', 'icon': Icons.tv, 'color': Colors.orange},
    {'name': 'Habillement Homme', 'icon': Icons.man, 'color': Colors.indigo},
    {'name': 'Habillement Femme', 'icon': Icons.woman, 'color': Colors.pink},
    {'name': 'Parfumerie & Beauté', 'icon': Icons.face, 'color': Colors.purple},
    {'name': 'Alimentation & PGC', 'icon': Icons.shopping_basket, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue & Catégories SOUKI'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: (cat['color'] as Color).withOpacity(0.1),
                  child: Icon(cat['icon'], color: cat['color'], size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  cat['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
