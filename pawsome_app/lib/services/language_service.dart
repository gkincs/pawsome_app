import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ez az osztály felelős az alkalmazás nyelvének kezeléséért.
/// A kiválasztott nyelvet eltárolja a SharedPreferences-be.
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en');

  LanguageService() {
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final String? savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
} 