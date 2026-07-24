import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dialogue de saisie du code PIN, utilisé pour sécuriser
/// les opérations sensibles (validation crédit BNPL, recharge, etc.)
class PinVerificationDialog extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const PinVerificationDialog({super.key, required this.onAuthenticated});

  @override
  State<PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;

  // TODO: remplacer par une vérification réelle (backend / stockage sécurisé)
  static const String _mockPin = '1234';

  void _verify() {
    if (_pinController.text == _mockPin) {
      Navigator.pop(context);
      widget.onAuthenticated();
    } else {
      setState(() {
        _errorText = 'Code PIN incorrect';
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vérification sécurisée'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Entrez votre code PIN pour confirmer.'),
          const SizedBox(height: 12),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: InputDecoration(
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _verify,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
