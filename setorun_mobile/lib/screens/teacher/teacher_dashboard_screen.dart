import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; 
import 'fill_mutabaah_screen.dart';
import '../shared/quran_page.dart';
import '../shared/chat_page.dart';
import '../shared/profile_page.dart';
import '../shared/video_call_screen.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';      
import '../../services/storage_service.dart'; 

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
  // Variabel penampung data dari backend
  List<dynamic> _pendingMurid = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingMurid(); 
  }

  // Fungsi untuk mengambil data antrean dari Django
  Future<void> _fetchPendingMurid() async {
    setState(() => _isLoading = true);
    try {
      final storage = StorageService();
      final apiClient = ApiClient(storage);
      
      final response = await apiClient.dio.get('/halaqoh/pending-murid/');
      
      if (mounted) {
        setState(() {
          _pendingMurid = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat daftar antrean murid.')),
        );
      }
    }
  }

  // Fungsi untuk menerima/menolak murid
  Future<void> _prosesMurid(int muridId, String action) async {
    try {
      final storage = StorageService();
      final apiClient = ApiClient(storage);
      
      await apiClient.dio.post(
        '/halaqoh/approve-murid/$muridId/',
        data: {'action': action},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approve' ? 'Berhasil menyetujui murid!' : 'Murid ditolak.'),
            backgroundColor: action == 'approve' ? Colors.teal : Colors.red,
          ),
        );
        _fetchPendingMurid();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat memproses murid.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final namaGuru = auth.user?.fullName ?? 'Guru';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchPendingMurid, 
        color: Colors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Statistik
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Kelas', '1', Icons.class_)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Total Murid', '-', Icons.people)),
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
              
              // Tampilkan loading, list kosong, atau daftar murid
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.teal))
              else if (_pendingMurid.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Belum ada murid yang antre.', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pendingMurid.length,
                  itemBuilder: (context, index) {
                    final murid = _pendingMurid[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          // MENGGUNAKAN withValues
                          backgroundColor: Colors.teal.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: Colors.teal.shade700),
                        ),
                        title: Text(murid['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Gender: ${murid['gender'] == 'male' ? 'Laki-laki' : 'Perempuan'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Tolak
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent),
                              onPressed: () => _prosesMurid(murid['id'], 'reject'),
                            ),
                            // Tombol Terima
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.teal, size: 28),
                              onPressed: () => _prosesMurid(murid['id'], 'approve'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      // MENGGUNAKAN withValues
      decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
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
        // MENGGUNAKAN withValues
        CircleAvatar(backgroundColor: Colors.teal.withValues(alpha: 0.2), child: Icon(icon, color: Colors.teal)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}