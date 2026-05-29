import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import 'account_settings_page.dart';
import 'language_settings_page.dart';
import 'theme_settings_page.dart';

class ProfilePage extends StatelessWidget {
  final String role;

  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.user;
    final namaUser = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (role == 'Guru' ? 'Guru' : 'Murid');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.t('Profil', 'Profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              namaUser,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(role, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ),
          if (user?.halaqoh != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  user!.halaqoh!.name,
                  style: TextStyle(fontSize: 13, color: Colors.teal.shade600),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              settings.t('Pengaturan', 'Settings'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _buildMenuItem(
            context,
            Icons.person_outline,
            settings.t('Akun', 'Account'),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
            ),
          ),
          _buildMenuItem(
            context,
            Icons.language,
            settings.t('Bahasa', 'Language'),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
            ),
          ),
          _buildMenuItem(
            context,
            Icons.dark_mode_outlined,
            settings.t('Tema', 'Theme'),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
            ),
          ),
          const Divider(),
          _buildMenuItem(
            context,
            Icons.logout,
            'Logout',
            () async => context.read<AuthProvider>().logout(),
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.teal),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
