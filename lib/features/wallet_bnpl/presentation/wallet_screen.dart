import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/security/app_security.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _creditDisponible = 0;
  double _creditUtilise = 0;
  bool _loading = true;
  bool _actionEnCours = false;
  String? _boutiquierId;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final boutiquier = await Supabase.instance.client
          .from('boutiquiers')
          .select('id, credit_disponible, credit_utilise')
          .eq('auth_user_id', userId)
          .single();

      if (!mounted) return;
      setState(() {
        _boutiquierId = boutiquier['id'];
        _creditDisponible = (boutiquier['credit_disponible'] as num).toDouble();
        _creditUtilise = (boutiquier['credit_utilise'] as num).toDouble();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement portefeuille : $e')),
      );
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _recharger() async {
    try {
      if (_actionEnCours) return;
      setState(() => _actionEnCours = true);
      bool authenticated = false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PinVerificationDialog(
          onAuthenticated: () {
            authenticated = true;
          },
        ),
      );
      if (authenticated) {
        await _executeRecharge(context);
      } else {
        if (mounted) setState(() => _actionEnCours = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _actionEnCours = false);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _executeRecharge(BuildContext context) async {
    if (_boutiquierId == null || !mounted) return;
    setState(() => _actionEnCours = true);
    const montantRecharge = 5000.0;

    try {
      final nouveauCredit = _creditDisponible + montantRecharge;

      await Supabase.instance.client
          .from('boutiquiers')
          .update({'credit_disponible': nouveauCredit})
          .eq('id', _boutiquierId as Object);

      await Supabase.instance.client.from('transactions_wallet').insert({
        'boutiquier_id': _boutiquierId,
        'type': 'recharge',
        'montant': montantRecharge,
      });

      if (!mounted) return;
      setState(() {
        _creditDisponible = nouveauCredit;
        _actionEnCours = false;
      });
      _showSuccess('Recharge de ${montantRecharge.toStringAsFixed(0)} MRU effectuée avec succès.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionEnCours = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la recharge : $e')),
      );
    }
  }

  Future<void> _rembourser() async {
    if (_creditUtilise <= 0) {
      _showSuccess('Aucun crédit à rembourser pour le moment.');
      return;
    }
    if (_actionEnCours) return;
    setState(() => _actionEnCours = true);
    bool authenticated = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PinVerificationDialog(
        onAuthenticated: () {
          authenticated = true;
        },
      ),
    );
    if (authenticated) {
      await _executeRemboursement(context);
    } else {
      if (mounted) setState(() => _actionEnCours = false);
    }
  }

  Future<void> _executeRemboursement(BuildContext context) async {
    if (_boutiquierId == null || !mounted) return;
    setState(() => _actionEnCours = true);
    final montantRembourse = _creditUtilise;

    try {

      await Supabase.instance.client
          .from('boutiquiers')
          .update({
              'credit_utilise': 0,
          })
          .eq('id', _boutiquierId as Object);

      await Supabase.instance.client.from('transactions_wallet').insert({
        'boutiquier_id': _boutiquierId,
        'type': 'remboursement',
        'montant': montantRembourse,
      });

      if (!mounted) return;
      setState(() {
        _creditUtilise = 0;
        _actionEnCours = false;
      });
      _showSuccess('Remboursement effectué avec succès.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionEnCours = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du remboursement : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Portefeuille BNPL'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _actionEnCours ? null : _recharger,
                    child: _actionEnCours
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Recharger'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _actionEnCours ? null : _rembourser,
                    child: const Text('Rembourser'),
                  ),
                ],
              ),
            ),
    );
  }
}
