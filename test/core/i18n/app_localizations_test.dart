import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

void main() {
  // Ensure the Flutter bindings are initialized so rootBundle is available in tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  test('loads Spanish translations', () async {
    final loc = await AppLocalizations.load(const Locale('es'));
    expect(loc.t('no_lunar_data'), 'No hay datos de fases lunares disponibles');
    expect(loc.t('retry'), 'Reintentar');
    expect(loc.t('opening_details'), 'Abriendo detalles de {name}...');
  });

  test('loads English translations', () async {
    final loc = await AppLocalizations.load(const Locale('en'));
    expect(loc.t('no_lunar_data'), 'No lunar phase data available');
    expect(loc.t('retry'), 'Retry');
    expect(loc.t('opening_details'), 'Opening {name} details...');
  });
}
