import 'package:flutter/material.dart';
import '../../models/murid_home_model.dart';
import '../../services/api_client.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../shared/chat_page.dart';
import '../shared/video_call_screen.dart';
import 'jadwal_riwayat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeService _homeService;
  MuridHomeModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final storage = StorageService();
    _homeService = HomeService(ApiClient(storage));
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _homeService.fetchMuridHome();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Gagal memuat data home'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    final data = _data!;

    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Pake fallback kalau nama null
              'Assalamu\'alaikum, ${data.nama ?? 'Murid'} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Semangat menghafal hari ini!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            
            // Pengecekan halaqohNama secara aman
            if ((data.halaqohNama ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${data.halaqohNama ?? 'Belum ada halaqah'} • ${data.guruNama ?? '-'}',
                style: TextStyle(color: Colors.teal.shade700, fontSize: 13),
              ),
            ],
            
            const SizedBox(height: 24),
            const Text(
              'Progress Hafalan (Juz 30)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                // Pake fallback 0 kalau progress null
                value: (data.progressPercent ?? 0) / 100,
                minHeight: 12,
                backgroundColor: Colors.teal.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.progressPercent ?? 0}% selesai',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(Icons.video_call, 'Setor', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoCallScreen(role: 'Murid'),
                    ),
                  );
                }),
                _buildQuickActionButton(Icons.chat, 'Chat', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatPage(role: 'Murid'),
                    ),
                  );
                }),
                _buildQuickActionButton(Icons.calendar_month, 'Jadwal', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JadwalPage(
                        // Kasih string fallback biar JadwalPage gak crash
                        jadwal: data.jadwal ?? 'Belum ada jadwal',
                        halaqohNama: data.halaqohNama ?? 'Belum ada halaqah',
                        guruNama: data.guruNama ?? '-',
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Terakhir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RiwayatListPage(items: data.riwayat ?? []),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
            
            // Pengecekan aman list riwayat
            if ((data.riwayat ?? []).isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada riwayat mutabaah', style: TextStyle(color: Colors.grey)),
              )
            else
              ...(data.riwayat ?? []).take(3).map(
                    (item) => _buildHistoryTile(
                      item.judul ?? 'Tanpa Judul',
                      (item.tanggalLabel ?? '').isNotEmpty ? item.tanggalLabel! : (item.noteDisplay ?? '-'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal.withValues(alpha: 0.15),
            child: Icon(icon, color: Colors.teal, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}