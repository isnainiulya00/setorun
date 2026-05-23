import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String role; // Menerima peran (Guru atau Murid)

  const VideoCallScreen({super.key, required this.role});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Warna dasar gelap khas video call
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Layar Video Utama (Lawan Bicara)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 120, color: Colors.grey.shade800),
                  const SizedBox(height: 16),
                  Text(
                    widget.role == 'Guru' ? 'Menunggu setoran Murid...' : 'Ustazah Isna (Tersambung)',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),

            // 2. Layar Video Kecil (Diri Sendiri)
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.person, color: Colors.white54, size: 40)),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.role == 'Guru' ? 'Anda (Guru)' : 'Anda (Murid)',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Label Keamanan (Opsional biar terlihat pro)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.green, size: 14),
                    SizedBox(width: 6),
                    Text('Terenkripsi', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),

            // 4. Fitur Khusus Berdasarkan Role
            if (widget.role == 'Guru')
              Positioned(
                left: 20,
                bottom: 120,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menampilkan jendela Form Mutaba\'ah...')),
                    );
                  },
                  icon: const Icon(Icons.edit_document),
                  label: const Text('Isi Nilai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              Positioned(
                left: 20,
                bottom: 120,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ustazah melihat Anda mengangkat tangan')),
                    );
                  },
                  icon: const Icon(Icons.pan_tool),
                  label: const Text('Tanya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // 5. Tombol Kontrol Bawah (Mic, Tutup, Kamera)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.grey.shade800,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconSize: 32,
                    padding: 16,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildControlButton(
                    icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                    color: _isVideoOn ? Colors.grey.shade800 : Colors.red,
                    onTap: () => setState(() => _isVideoOn = !_isVideoOn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi bantuan untuk membuat tombol bulat
  Widget _buildControlButton({required IconData icon, required Color color, double iconSize = 24, double padding = 12, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}