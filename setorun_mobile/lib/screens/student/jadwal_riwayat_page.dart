import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mutabaah_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_client.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';

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

class RiwayatListPage extends StatefulWidget {
  const RiwayatListPage({super.key});

  @override
  State<RiwayatListPage> createState() => _RiwayatListPageState();
}

class _RiwayatListPageState extends State<RiwayatListPage> {
  late final MutabaahService _service;
  List<MutabaahModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = MutabaahService(ApiClient(StorageService()));
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.fetchList();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Semua Riwayat', 'All History')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: _load,
              color: Colors.teal,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(child: Text(settings.t('Belum ada riwayat', 'No history yet'))),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
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
            ),
    );
  }
}
