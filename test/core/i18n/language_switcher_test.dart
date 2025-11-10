import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/language_switcher.dart';
import 'package:skyshare_frontend_mobile/core/i18n/locale_provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

void main() {
  testWidgets('LanguageSwitcher renders and changes locale', (WidgetTester tester) async {
    final provider = LocaleProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<LocaleProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en'), Locale('es')],
          home: Scaffold(
            appBar: AppBar(
              actions: const [LanguageSwitcher()],
            ),
          ),
        ),
      ),
    );

    // Verifica que el icono está presente
    expect(find.byIcon(Icons.language), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(provider.locale.languageCode, 'en');
  });

  testWidgets('LanguageSwitcher does not render if provider is missing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: const [LanguageSwitcher()],
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.language), findsNothing);
  });
}
