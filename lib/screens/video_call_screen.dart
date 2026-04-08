import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

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
              color: Colors.white.withOpacity(0.3),
            ),
          ),

          // 📍 Info
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              "Terhubung dengan Ustadz Ahmad",
              style: TextStyle(color: Colors.white),
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
                _buildButton(Icons.mic, "Mic"),
                _buildButton(Icons.videocam, "Camera"),
                _buildEndCallButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
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
