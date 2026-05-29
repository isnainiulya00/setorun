import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mutabaah_model.dart';
import '../../providers/settings_provider.dart';

class JadwalPage extends StatelessWidget {
  final String jadwal;
  final String halaqohNama;
  final String guruNama;

  const JadwalPage({
    super.key,
    required this.jadwal,
    required this.halaqohNama,
    required this.guruNama,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Jadwal Setoran', 'Recitation Schedule')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(halaqohNama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${settings.t("Guru", "Teacher")}: $guruNama'),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        jadwal,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RiwayatListPage extends StatelessWidget {
  final List<MutabaahModel> items;

  const RiwayatListPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Semua Riwayat', 'All History')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? Center(child: Text(settings.t('Belum ada riwayat', 'No history yet')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.menu_book, color: Colors.white, size: 20),
                    ),
                    title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.tanggalLabel} • ${item.noteDisplay}'),
                    trailing: Text(item.status, style: const TextStyle(color: Colors.green)),
                  ),
                );
              },
            ),
    );
  }
}
