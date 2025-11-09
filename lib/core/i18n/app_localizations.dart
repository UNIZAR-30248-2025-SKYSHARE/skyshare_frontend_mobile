import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    final jsonString = await rootBundle.loadString('lib/core/i18n/translations/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    localizations._strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
    return localizations;
  }

  /// Translate [key]. Optionally pass [args] to replace placeholders like {name}.
  String t(String key, [Map<String, String>? args]) {
    String value = _strings[key] ?? key;
    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
