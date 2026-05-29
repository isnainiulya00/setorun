import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._settings) {
    initialize();
  }

  final SettingsService _settings;
  AppLanguage language = AppLanguage.id;
  AppThemeMode themeMode = AppThemeMode.light;
  bool isReady = false;

  Future<void> initialize() async {
    language = await _settings.getLanguage();
    themeMode = await _settings.getThemeMode();
    isReady = true;
    notifyListeners();
  }

  bool get isDarkMode => themeMode == AppThemeMode.dark;

  String t(String idText, String enText) {
    return language == AppLanguage.en ? enText : idText;
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    await _settings.setLanguage(value);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    themeMode = value;
    await _settings.setThemeMode(value);
    notifyListeners();
  }
}
