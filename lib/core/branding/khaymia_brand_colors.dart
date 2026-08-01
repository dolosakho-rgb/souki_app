import 'package:flutter/material.dart';

/// KHAYMIA Design System — Branding
/// Source unique de verite pour la palette officielle (Brand Book KHAYMIA V2).
///
/// Ce fichier est additif : il ne remplace pas `app_colors.dart` (utilise par
/// les ecrans existants Boutiquier/Admin) et n'est utilise que par les
/// nouveaux modules (Consommateur, Grossiste, Livreur...) jusqu'a
/// l'harmonisation complete de l'application.
class KhaymiaBrandColors {
  KhaymiaBrandColors._();

  /// Vert KHAYMIA — couleur primaire de la marque.
  static const Color primary = Color(0xFF0E5B3A);

  /// Ocre / Or — couleur d'accent.
  static const Color accent = Color(0xFFD98E3A);

  /// Anthracite — texte principal.
  static const Color textPrimary = Color(0xFF1E2328);

  /// Off White — fond principal des ecrans.
  static const Color background = Color(0xFFFAF8F5);

  /// Blanc pur — fond des cartes et surfaces.
  static const Color surface = Color(0xFFFFFFFF);

  /// Gris clair — bordures et separateurs.
  static const Color border = Color(0xFFE5E7EB);

  /// Gris secondaire — texte secondaire / attenue.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Vert succes — confirmations, etats positifs.
  static const Color success = Color(0xFF16A34A);

  /// Ambre avertissement — alertes non bloquantes.
  static const Color warning = Color(0xFFF59E0B);

  /// Rouge erreur — echecs, actions destructives.
  static const Color error = Color(0xFFDC2626);

  /// Bleu information — messages neutres/informatifs.
  static const Color info = Color(0xFF2563EB);
}
