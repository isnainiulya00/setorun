import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'placeholder_screen.dart';

class ProfilePage extends StatelessWidget {
  final String role;

  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final namaUser = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (role == 'Guru' ? 'Guru' : 'Murid');
    final halaqohName = user?.halaqoh?.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            namaUser,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            role,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          if (user?.gender.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              user!.genderLabel,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          if (halaqohName != null) ...[
            const SizedBox(height: 4),
            Text(
              halaqohName,
              style: TextStyle(fontSize: 13, color: Colors.teal.shade600),
            ),
          ],
          if (user?.email.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              user!.email,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 40),
          _buildMenuItem(context, Icons.person, 'Akun'),
          _buildMenuItem(context, Icons.language, 'Bahasa'),
          _buildMenuItem(context, Icons.dark_mode, 'Tema'),
          _buildMenuItem(context, Icons.logout, 'Logout', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        if (isLogout) {
          await context.read<AuthProvider>().logout();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceholderScreen(title: title),
          ),
        );
      },
    );
  }
}
