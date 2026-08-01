import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/branding/khaymia_brand_colors.dart';

// TODO(architecture): cet écran interroge Supabase directement pour cette
// première étape. Une refactorisation Clean Architecture introduira un
// ConsumerRepository afin de découpler la couche présentation de l'accès
// aux données.
class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  String prenom = '';
  String nom = '';
  String villeNom = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          setState(() {
            errorMessage = 'Session invalide. Veuillez vous reconnecter.';
            isLoading = false;
          });
        }
        return;
      }
      final data = await Supabase.instance.client
          .from('users')
          .select('prenom, nom, villes(nom)')
          .eq('auth_user_id', userId)
          .single();
      // TODO(security): renforcer la gestion des profils absents ou multiples
      // après stabilisation du module identité.
      if (mounted) {
        setState(() {
          prenom = data['prenom'] as String? ?? '';
          nom = data['nom'] as String? ?? '';
          final ville = data['villes'];
          villeNom = (ville is Map && ville['nom'] != null) ? ville['nom'] as String : '';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Impossible de charger votre profil. Reessayez.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KhaymiaBrandColors.background,
      appBar: AppBar(
        backgroundColor: KhaymiaBrandColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // TODO(i18n): titre a externaliser lors de la mise en place du systeme de traduction.
        title: const Text('KHAYMIA'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: KhaymiaBrandColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: KhaymiaBrandColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: KhaymiaBrandColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: KhaymiaBrandColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: KhaymiaBrandColors.background,
                              child: Icon(Icons.person, size: 36, color: KhaymiaBrandColors.textSecondary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TODO(i18n): texte a externaliser lors de la mise en place du systeme de traduction.
                                  Text(
                                    'Bienvenue, $prenom $nom',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: KhaymiaBrandColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (villeNom.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: KhaymiaBrandColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          villeNom,
                                          style: const TextStyle(color: KhaymiaBrandColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // TODO(i18n): labels a externaliser lors de la mise en place du systeme de traduction.
                      _buildMenuCard(icon: Icons.storefront, label: 'Catalogue'),
                      const SizedBox(height: 12),
                      _buildMenuCard(icon: Icons.receipt_long, label: 'Mes commandes'),
                      const SizedBox(height: 12),
                      _buildMenuCard(icon: Icons.person_outline, label: 'Mon profil'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: KhaymiaBrandColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KhaymiaBrandColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: KhaymiaBrandColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: KhaymiaBrandColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: KhaymiaBrandColors.textSecondary),
        ],
      ),
    );
  }
}
