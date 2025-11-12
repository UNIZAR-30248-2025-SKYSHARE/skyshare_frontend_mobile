import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

export 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class FakeLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => _FakeAppLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

class _FakeAppLocalizations extends AppLocalizations {
  _FakeAppLocalizations() : super(const Locale('es'));

  @override
  String t(String key, [Map<String, String>? args]) => key;
}