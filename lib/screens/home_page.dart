import 'package:flutter/material.dart';
import 'video_call_screen.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👋 Greeting
          const Text(
            "Assalamu’alaikum, Isna 👋",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Semangat menghafal hari ini!",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // 📘 Card Halaqoh
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ListTile(
              leading: Icon(Icons.menu_book, color: Colors.teal),
              title: Text("Halaqoh Al-Fatih"),
              subtitle: Text("Senin & Rabu • Ustadz Ahmad"),
            ),
          ),

          const SizedBox(height: 20),

          // 📊 Progress
          const Text(
            "Progress Hafalan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          const Text("60% selesai"),

          const SizedBox(height: 20),

          // ⚡ Quick Actions
          const Text(
            "Aksi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(Icons.video_call, "Setor", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoCallScreen(),
                  ),
                );
              }),
              _buildButton(Icons.chat, "Chat", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                ); 
              }),
            ],
          ),

          const SizedBox(height: 20),

          // 🕒 Riwayat
          const Text(
            "Riwayat Terakhir",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Setor Al-Baqarah 1-5"),
            subtitle: Text("Kemarin"),
          ),
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Murajaah An-Nas"),
            subtitle: Text("2 hari lalu"),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.teal.shade100,
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
