import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'SOUKI - Tableau de bord',
      'credit_limit': 'Plafond Crédit Disponible',
      'quick_access': 'Accès Rapide',
      'catalog': 'Catalogue',
      'delivery': 'Livraisons',
      'insurance': 'Assurance',
      'insights': 'Insights',
    },
    'ar': {
      'app_title': 'سوكى - لوحة القيادة',
      'credit_limit': 'الحد الائتماني المتاح',
      'quick_access': 'الوصول السريع',
      'catalog': 'الكتالوج',
      'delivery': 'التوصيل',
      'insurance': 'التأمين',
      'insights': 'الرؤى والتحليلات',
    },
    'sn': {
      'app_title': 'SOUKI - Kanno Koron',
      'credit_limit': 'Kredit Baara Labu',
      'quick_access': 'Wali Kabu',
      'catalog': 'Nafa Fello',
      'delivery': 'Faamu Na',
      'insurance': 'Haki Karama',
      'insights': 'Kelen Yere',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['fr']![key]!;
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'ar', 'sn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
