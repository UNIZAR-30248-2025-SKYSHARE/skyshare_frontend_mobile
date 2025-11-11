import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _kPrefKey = 'preferred_locale';

  Locale _locale = const Locale('es');
  bool _initialized = false;

  Locale get locale => _locale;
  bool get initialized => _initialized;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kPrefKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    } else {
      // Leave default (es)
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefKey);
    _locale = const Locale('es');
    notifyListeners();
  }
}
