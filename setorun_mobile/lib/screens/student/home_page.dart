import 'dart:async';

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
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    final storage = StorageService();
    _homeService = HomeService(ApiClient(storage));
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _homeService.fetchMuridHome();
      if (!mounted) return;
      final wasPending = _data?.statusJoin == 'pending';
      setState(() {
        _data = data;
        _loading = false;
        _error = null;
      });
      if (wasPending && data.statusJoin == 'approved' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat! Kamu sudah disetujui bergabung ke halaqoh.'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (!mounted || silent) return;
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
            const Text('Gagal memuat data home', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // --- INI DETEKTIFNYA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
            // -----------------------
            
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    final data = _data!;

    // ==========================================
    // 1. TAMPILAN JIKA MASIH PENDING
    // ==========================================
    if (data.statusJoin == 'pending') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_bottom, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Menunggu Persetujuan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Assalamu\'alaikum ${data.nama},\nAkunmu sedang direview oleh Guru.\nSilakan tunggu dan refresh halaman ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    // ==========================================
    // 2. TAMPILAN JIKA DITOLAK
    // ==========================================
    if (data.statusJoin == 'rejected') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Pendaftaran Ditolak', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Maaf, permintaan kamu untuk bergabung ke halaqah ini ditolak oleh Guru. Silakan hubungi admin atau daftar ke halaqah lain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================
    // 3. TAMPILAN NORMAL (JIKA SUDAH APPROVED)
    // ==========================================
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
            
            if (data.halaqohNama.isNotEmpty) ...[
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
                        builder: (context) => const RiwayatListPage(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
            
            if (data.riwayat.isEmpty)
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