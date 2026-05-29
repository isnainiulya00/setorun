import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart'; 

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  void _startJitsiCall() async {
    try {
      String roomName = "setorun-halaqah-ahmad-12345"; 

      var options = JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: "Nama Murid", 
        userEmail: "murid@setorun.com",
        isAudioMuted: false,
        isVideoMuted: false,
      );

      await JitsiMeetWrapper.joinMeeting(options: options);
    } catch (error) {
      debugPrint("Gagal masuk Jitsi: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Setor via Video Call"),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // 📹 Background simulasi kamera
          Center(
            child: Icon(
              Icons.videocam,
              size: 120,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),

          // 📍 Info
          const Positioned(
            top: 20,
            left: 20,
            child: Text(
              "Terhubung dengan Ustadz Ahmad",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // 🔘 Controls bawah
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(Icons.mic, "Mic", () {}),
                
                // 👇 Tombol kamera ini sekarang bisa diklik untuk masuk ke panggilan Jitsi asli!
                _buildButton(Icons.video_call, "Masuk Jitsi", () {
                  _startJitsiCall(); 
                }),
                
                _buildEndCallButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menambahkan parameter VoidCallback agar tombolnya bisa menerima perintah klik
  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.red,
            child: Icon(Icons.call_end, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        const Text("End", style: TextStyle(color: Colors.white)),
      ],
    );
  }
}