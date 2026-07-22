import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  final List<Map<String, dynamic>> _deliveries = const [
    {
      'id': 'CMD-2026-089',
      'items': 'Smartphone 4G LTE (x2)',
      'status': 'En cours de livraison',
      'step': 2,
      'driver': 'Mohamed Ould Ahmed (Tel: +222 36 00 00 00)',
      'eta': "Aujourd'hui, 14:30",
    },
    {
      'id': 'CMD-2026-072',
      'items': 'Boubou Traditionnel Homme (x5)',
      'status': 'Livrée',
      'step': 3,
      'driver': 'Cheikh Sid El Moctar',
      'eta': 'Livré le 21 Juil',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Livraisons SOUKI'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deliveries.length,
        itemBuilder: (context, index) {
          final delivery = _deliveries[index];
          final step = delivery['step'] as int;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(delivery['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Chip(
                        label: Text(delivery['status'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                        backgroundColor: step == 3 ? Colors.green : AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(delivery['items'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: step == 3 ? 1.0 : 0.6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(step == 3 ? Colors.green : AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Livreur : ${delivery['driver']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'ETA : ${delivery['eta']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
