import 'package:flutter/material.dart';

import '../../models/mutabaah_model.dart';
import '../../services/api_client.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';

class MutabaahPage extends StatefulWidget {
  const MutabaahPage({super.key});

  @override
  State<MutabaahPage> createState() => _MutabaahPageState();
}

class _MutabaahPageState extends State<MutabaahPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutabaah Hafalan'),
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
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Belum ada data mutabaah dari guru')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            title: Text(item.judul),
                            subtitle: Text(
                              '${item.tanggalLabel} • ${item.noteDisplay}',
                            ),
                            trailing: Text(
                              item.status,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
