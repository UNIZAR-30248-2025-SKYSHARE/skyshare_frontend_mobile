import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

void main() {
  // Inicializa bindings de Flutter para usar rootBundle en tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations', () {
    test('loads Spanish translations', () async {
      final loc = await AppLocalizations.load(const Locale('es'));
      expect(loc.t('no_lunar_data'), 'No hay datos de fases lunares disponibles');
      expect(loc.t('retry'), 'Reintentar');
      expect(loc.t('opening_details', {'name': 'Luna'}), 'Abriendo detalles de Luna...');
    });

    test('loads English translations', () async {
      final loc = await AppLocalizations.load(const Locale('en'));
      expect(loc.t('no_lunar_data'), 'No lunar phase data available');
      expect(loc.t('retry'), 'Retry');
      expect(loc.t('opening_details', {'name': 'Moon'}), 'Opening Moon details...');
    });

    test('returns key when translation missing', () async {
      final loc = await AppLocalizations.load(const Locale('es'));
      expect(loc.t('non_existing_key'), 'non_existing_key');
    });

    test('placeholder replacement works correctly', () async {
      final loc = await AppLocalizations.load(const Locale('en'));
      final result = loc.t('opening_details', {'name': 'Mars'});
      expect(result, 'Opening Mars details...');
    });

    test('supported locales include en and es', () {
      final locales = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(locales, containsAll(['en', 'es']));
    });
  });
}
