import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { id, en }

enum AppThemeMode { light, dark }

class SettingsService {
  static const _languageKey = 'app_language';
  static const _themeKey = 'app_theme';

  Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_languageKey) ?? 'id';
    return value == 'en' ? AppLanguage.en : AppLanguage.id;
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageKey,
      language == AppLanguage.en ? 'en' : 'id',
    );
  }

  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey) ?? 'light';
    return value == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == AppThemeMode.dark ? 'dark' : 'light',
    );
  }
}
