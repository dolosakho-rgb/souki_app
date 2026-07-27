import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';

/// Dialogue de saisie du code PIN, utilisé pour sécuriser
/// les opérations sensibles (validation crédit BNPL, recharge, etc.)
class PinVerificationDialog extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const PinVerificationDialog({super.key, required this.onAuthenticated});

  @override
  State<PinVerificationDialog> createState() =>
      _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  Future<void> _verify() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      setState(() {
        _errorText = 'Le code PIN doit contenir 6 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    final email = currentUser?.email;

    if (email == null) {
      setState(() {
        _isLoading = false;
        _errorText = 'Session invalide. Veuillez vous reconnecter.';
      });
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: pin,
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.pop(context);
        widget.onAuthenticated();
      } else {
        setState(() {
          _isLoading = false;
          _errorText = 'Code PIN incorrect';
        });
      }
    } on AuthException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Code PIN incorrect';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Erreur de connexion. Réessayez.';
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
            maxLength: 6,
            enabled: !_isLoading,
            decoration: InputDecoration(
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _verify,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirmer'),
        ),
      ],
    );
  }
}
