import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/security/app_security.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // TODO: remplacer par les vraies données Firestore
  double _creditDisponible = 15000;
  double _creditUtilise = 5000;

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _recharger() {
    showDialog(
      context: context,
      builder: (context) => PinVerificationDialog(
        onAuthenticated: () {
          setState(() {
            _creditDisponible += 5000;
          });
          _showSuccess('Recharge de 5 000 MRU effectuée avec succès.');
        },
      ),
    );
  }

  void _rembourser() {
    if (_creditUtilise <= 0) {
      _showSuccess('Aucun crédit à rembourser pour le moment.');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => PinVerificationDialog(
        onAuthenticated: () {
          setState(() {
            _creditDisponible += _creditUtilise;
            _creditUtilise = 0;
          });
          _showSuccess('Remboursement effectué avec succès.');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Portefeuille BNPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crédit disponible',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_creditDisponible.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crédit utilisé',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '${_creditUtilise.toStringAsFixed(0)} MRU',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _recharger,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Recharger'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rembourser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Rembourser'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
