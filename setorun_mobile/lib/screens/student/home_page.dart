import 'package:flutter/material.dart';
import '../shared/video_call_screen.dart';
import '../shared/chat_page.dart';
import '../shared/placeholder_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👋 Greeting
          const Text(
            "Assalamu’alaikum, Isna 👋",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Semangat menghafal hari ini!",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),

          // 📘 Card Halaqoh (Bisa diklik -> Placeholder)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaceholderScreen(title: 'Detail Halaqoh Al-Fatih'),
                ),
              );
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.menu_book, color: Colors.white),
                ),
                title: Text("Halaqoh Al-Fatih", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Senin & Rabu • Ust. Ahmad"),
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 📊 Progress Hafalan
          const Text(
            "Progress Hafalan (Juz 30)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 12,
              backgroundColor: Colors.teal.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
          const SizedBox(height: 8),
          const Text("60% selesai", style: TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 24),

          // ⚡ Quick Actions
          const Text(
            "Aksi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tombol Setor -> Masuk Video Call Murid
              _buildQuickActionButton(Icons.video_call, "Setor", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoCallScreen(role: 'Murid')),
                );
              }),
              
              // Tombol Chat -> Masuk Chat Detail Murid
              _buildQuickActionButton(Icons.chat, "Chat", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage(role: 'Murid')),
                );
              }),
              
              // Tombol Jadwal -> Masuk Placeholder
              _buildQuickActionButton(Icons.calendar_month, "Jadwal", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Jadwal Setoran')),
                );
              }),
            ],
          ),

          const SizedBox(height: 32),

          // 🕒 Riwayat Terakhir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat Terakhir",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Semua Riwayat')),
                  );
                },
                child: const Text("Lihat Semua", style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
          
          // List Riwayat (Bisa diklik -> Placeholder)
          _buildHistoryTile(context, "Setor Al-Baqarah 1-5", "Kemarin", Icons.check_circle, Colors.green),
          _buildHistoryTile(context, "Murajaah An-Nas", "2 hari lalu", Icons.check_circle, Colors.green),
          _buildHistoryTile(context, "Setor Al-Fatihah", "3 hari lalu", Icons.access_time_filled, Colors.orange),
        ],
      ),
    );
  }

  // Fungsi Bantuan untuk Tombol Bulat
  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal.withOpacity(0.15),
            child: Icon(icon, color: Colors.teal, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Fungsi Bantuan untuk List Riwayat
  Widget _buildHistoryTile(BuildContext context, String title, String subtitle, IconData icon, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceholderScreen(title: 'Detail: $title'),
            ),
          );
        },
      ),
    );
  }
}