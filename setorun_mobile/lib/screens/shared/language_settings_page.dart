import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/settings_service.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Pengaturan Bahasa', 'Language Settings')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          RadioListTile<AppLanguage>(
            title: const Text('Bahasa Indonesia'),
            value: AppLanguage.id,
            groupValue: settings.language,
            activeColor: Colors.teal,
            onChanged: (v) => settings.setLanguage(v!),
          ),
          RadioListTile<AppLanguage>(
            title: const Text('English'),
            value: AppLanguage.en,
            groupValue: settings.language,
            activeColor: Colors.teal,
            onChanged: (v) => settings.setLanguage(v!),
          ),
        ],
      ),
    );
  }
}
