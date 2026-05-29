import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/settings_service.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Pengaturan Tema', 'Theme Settings')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          RadioListTile<AppThemeMode>(
            title: Text(settings.t('Mode Terang', 'Light Mode')),
            secondary: const Icon(Icons.light_mode, color: Colors.teal),
            value: AppThemeMode.light,
            groupValue: settings.themeMode,
            activeColor: Colors.teal,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
          RadioListTile<AppThemeMode>(
            title: Text(settings.t('Mode Gelap', 'Dark Mode')),
            secondary: const Icon(Icons.dark_mode, color: Colors.teal),
            value: AppThemeMode.dark,
            groupValue: settings.themeMode,
            activeColor: Colors.teal,
            onChanged: (v) => settings.setThemeMode(v!),
          ),
        ],
      ),
    );
  }
}
