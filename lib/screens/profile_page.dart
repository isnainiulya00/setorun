import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Foto Profil
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.png'), // optional
          ),

          const SizedBox(height: 10),
          const Text(
            "Nama User",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          // Menu List
          _buildMenuItem(Icons.person, "Akun"),
          _buildMenuItem(Icons.language, "Bahasa"),
          _buildMenuItem(Icons.dark_mode, "Tema"),
          _buildMenuItem(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // nanti isi logic
      },
    );
  }
}
