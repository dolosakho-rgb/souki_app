import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home_catalog/presentation/home_catalog_screen.dart';
import '../../../core/constants/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomController = TextEditingController();
  final _boutiqueNomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _adresseController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _villes = [];
  String? _selectedVilleId;
  bool _loadingVilles = true;

  @override
  void initState() {
    super.initState();
    _loadVilles();
  }

  Future<void> _loadVilles() async {
    try {
      final data = await Supabase.instance.client
          .from('villes')
          .select('id, nom')
          .order('nom');
      if (mounted) {
        setState(() {
          _villes = List<Map<String, dynamic>>.from(data);
          _loadingVilles = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingVilles = false);
    }
  }

  String _phoneToFakeEmail(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$digitsOnly@khaymia.internal';
  }

  Future<void> _signup() async {
    final nom = _nomController.text.trim();
    final boutiqueNom = _boutiqueNomController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final adresse = _adresseController.text.trim();

    if (nom.isEmpty || boutiqueNom.isEmpty || phone.isEmpty || pin.isEmpty || _selectedVilleId == null) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs obligatoires.');
      return;
    }

    if (pin.length != 6) {
      setState(() => _errorMessage = 'Le code PIN doit contenir 6 chiffres.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-boutiquier',
        body: {
          'nom': nom,
          'boutique_nom': boutiqueNom,
          'telephone': phone,
          'adresse': adresse,
          'pin': pin,
          'ville_id': _selectedVilleId,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final message = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Erreur lors de la creation du compte.';
        setState(() => _errorMessage = message);
        return;
      }

      await Supabase.instance.client.auth.signInWithPassword(
        email: _phoneToFakeEmail(phone),
        password: pin,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeCatalogScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Une erreur est survenue. Reessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _boutiqueNomController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inscription',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Creez votre compte commercant',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Votre nom complet'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _boutiqueNomController,
              decoration: const InputDecoration(labelText: 'Nom de la boutique'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Numero de telephone'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adresseController,
              decoration: const InputDecoration(labelText: 'Adresse (optionnel)'),
            ),
            const SizedBox(height: 16),
            _loadingVilles
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    initialValue: _selectedVilleId,
                    decoration: const InputDecoration(labelText: 'Ville'),
                    items: _villes
                        .map((v) => DropdownMenuItem<String>(
                              value: v['id'] as String,
                              child: Text(v['nom'] as String),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedVilleId = value),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Code PIN (6 chiffres)'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'S\'inscrire',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
