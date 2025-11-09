import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/locale_provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    // The LocaleProvider may not be present in some test contexts; fail silently
    // by not rendering the switcher if provider isn't available.
    try {
      final provider = context.watch<LocaleProvider>();
      final current = provider.locale.languageCode;

      final loc = AppLocalizations.of(context);
      return PopupMenuButton<String>(
        icon: const Icon(Icons.language, color: Colors.white),
        onSelected: (code) => provider.setLocale(Locale(code)),
        itemBuilder: (_) => [
          CheckedPopupMenuItem(
            value: 'es',
            checked: current == 'es',
            child: Text(loc?.t('language.spanish') ?? 'Español'),
          ),
          CheckedPopupMenuItem(
            value: 'en',
            checked: current == 'en',
            child: Text(loc?.t('language.english') ?? 'English'),
          ),
        ],
      );
    } catch (e) {
      // Provider not found (e.g., in unit tests); don't render the control.
      return const SizedBox.shrink();
    }
  }
}
