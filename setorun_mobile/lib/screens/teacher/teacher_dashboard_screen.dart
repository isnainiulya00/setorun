import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fill_mutabaah_screen.dart';
import '../shared/quran_page.dart';
import '../shared/chat_page.dart';
import '../shared/profile_page.dart';
import '../shared/video_call_screen.dart';
import '../../providers/auth_provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TeacherHomeContent(),
    const ChatPage(role: "Guru"),
    const QuranPage(),
    const ProfilePage(role: 'Guru'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class TeacherHomeContent extends StatefulWidget {
  const TeacherHomeContent({super.key});

  @override
  State<TeacherHomeContent> createState() => _TeacherHomeContentState();
}

class _TeacherHomeContentState extends State<TeacherHomeContent> {
  List<Map<String, String>> pendingTasks = [
    {'nama': 'Nadia', 'surah': 'An-Naba 1-10', 'waktu': 'Baru saja'},
    {'nama': 'Zuna', 'surah': 'An-Naziat 1-15', 'waktu': '10 mnt lalu'},
    {'nama': 'Ahmad', 'surah': '\'Abasa 1-20', 'waktu': '1 jam lalu'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final namaGuru = auth.user?.fullName ?? 'Guru';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assalamu\'alaikum, $namaGuru 👋', 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Semangat mengajar hari ini!', 
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),

            // Statistik (Tetap mockup/hardcode sementara)
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Kelas', '3', Icons.class_)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Total Murid', '15', Icons.people)),
              ],
            ),
            const SizedBox(height: 24),

            // Aksi Cepat
            const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoCallScreen(role: "Guru"))),
                  child: _buildQuickAction(Icons.video_call, 'Buka Kelas'),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FillMutabaahScreen())),
                  child: _buildQuickAction(Icons.edit_document, 'Isi Mutaba\'ah'),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage(role: 'Guru'))),
                  child: _buildQuickAction(Icons.chat, 'Chat Murid'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // List Pending
            const Text('Menunggu Persetujuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(pendingTasks[index]['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pendingTasks[index]['surah']!} • ${pendingTasks[index]['waktu']!}'),
                    trailing: ElevatedButton(
                      onPressed: () => setState(() => pendingTasks.removeAt(index)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      child: const Text('Setujui'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.2), child: Icon(icon, color: Colors.teal)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}