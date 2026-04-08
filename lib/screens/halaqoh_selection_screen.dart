import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class HalaqohSelectionScreen extends StatelessWidget {
  const HalaqohSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final halaqohList = [
      {"nama": "Halaqoh Al-Fatih", "jadwal": "Senin & Rabu"},
      {"nama": "Halaqoh An-Nur", "jadwal": "Selasa & Kamis"},
      {"nama": "Halaqoh Ar-Rahman", "jadwal": "Jumat"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Halaqoh")),
      body: ListView.builder(
        itemCount: halaqohList.length,
        itemBuilder: (context, index) {
          final halaqoh = halaqohList[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(halaqoh["nama"]!),
              subtitle: Text(halaqoh["jadwal"]!),
              trailing: ElevatedButton(
                onPressed: () {
                  // JOIN HALAQOH → MASUK DASHBOARD
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                child: const Text("Join"),
              ),
            ),
          );
        },
      ),
    );
  }
}
