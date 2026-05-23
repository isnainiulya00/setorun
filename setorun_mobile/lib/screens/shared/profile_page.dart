import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class ProfilePage extends StatelessWidget {
  final String role; // Menerima data role dari halaman sebelumnya

  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Logika penentuan nama berdasarkan role
    String namaUser = (role == 'Guru') ? 'Ustazah Isna' : 'Isnaini';

    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih sesuai kode Anda
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40), // Jarak atas diperbesar sedikit agar proporsional

          // Foto Profil
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal, // Warna dasar jika gambar tidak ada
            // Pastikan gambar profile.png ada di folder assets/images/
            // Jika belum ada, beri comment (//) pada baris backgroundImage di bawah ini
            backgroundImage: AssetImage('assets/images/profile.png'), 
          ),

          const SizedBox(height: 16),
          
          // Nama User (Dinamis)
          Text(
            namaUser,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          // Tambahan Label Role
          Text(
            role,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 40),

          // Menu List (Sesuai desain Anda)
          _buildMenuItem(context, Icons.person, "Akun"),
          _buildMenuItem(context, Icons.language, "Bahasa"),
          _buildMenuItem(context, Icons.dark_mode, "Tema"),
          _buildMenuItem(context, Icons.logout, "Logout", isLogout: true),
        ],
      ),
    );
  }

  // Fungsi bantuan untuk membuat List Menu
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
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
      onTap: () {
        if (isLogout) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          // ROUTING KE HALAMAN PLACEHOLDER
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceholderScreen(title: title), // Membawa nama menu
            ),
          );
        }
      },
    );
  }
}