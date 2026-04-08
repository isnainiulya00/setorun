import 'package:flutter/material.dart';

class MutabaahPage extends StatelessWidget {
  const MutabaahPage({super.key});

  final List<Map<String, String>> data = const [
    {
      "tanggal": "Senin, 7 April",
      "judul": "Al-Baqarah 1-5",
      "status": "Selesai"
    },
    {
      "tanggal": "Rabu, 5 April",
      "judul": "An-Nas",
      "status": "Selesai"
    },
    {
      "tanggal": "Senin, 3 April",
      "judul": "Al-Fatihah",
      "status": "Belum disetujui"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mutabaah Hafalan"),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item["status"] == "Selesai"
                    ? Colors.green
                    : Colors.orange,
                child: Icon(
                  item["status"] == "Selesai"
                      ? Icons.check
                      : Icons.schedule,
                  color: Colors.white,
                ),
              ),
              title: Text(item["judul"]!),
              subtitle: Text(item["tanggal"]!),
              trailing: Text(
                item["status"]!,
                style: TextStyle(
                  color: item["status"] == "Selesai"
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
