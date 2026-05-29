import 'package:flutter/material.dart';

import '../../models/murid_brief_model.dart';
import '../../services/api_client.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';

class FillMutabaahScreen extends StatefulWidget {
  const FillMutabaahScreen({super.key});

  @override
  State<FillMutabaahScreen> createState() => _FillMutabaahScreenState();
}

class _FillMutabaahScreenState extends State<FillMutabaahScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MutabaahService _mutabaahService;
  late final MuridService _muridService;

  List<MuridBriefModel> _muridList = [];
  int? _selectedMuridId;
  String _selectedNote = 'ziyadah';
  final TextEditingController _surahCtrl = TextEditingController();
  final TextEditingController _ayatMulaiCtrl = TextEditingController();
  final TextEditingController _ayatSelesaiCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();
  bool _loadingMurid = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final api = ApiClient(StorageService());
    _mutabaahService = MutabaahService(api);
    _muridService = MuridService(api);
    _loadMurid();
  }

  @override
  void dispose() {
    _surahCtrl.dispose();
    _ayatMulaiCtrl.dispose();
    _ayatSelesaiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMurid() async {
    try {
      final list = await _muridService.fetchMuridList();
      if (!mounted) return;
      setState(() {
        _muridList = list;
        if (list.isNotEmpty) _selectedMuridId = list.first.id;
        _loadingMurid = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMurid = false);
    }
  }

  Future<void> _simpanMutabaah() async {
    if (!_formKey.currentState!.validate() || _selectedMuridId == null) return;
    setState(() => _saving = true);
    try {
      await _mutabaahService.create(
        muridId: _selectedMuridId!,
        namaSurah: _surahCtrl.text.trim(),
        ayatMulai: int.parse(_ayatMulaiCtrl.text),
        ayatSelesai: int.parse(_ayatSelesaiCtrl.text),
        note: _selectedNote,
        keterangan: _catatanCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alhamdulillah, Mutaba\'ah berhasil disimpan!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      appBar: AppBar(
        title: const Text('Isi Mutaba\'ah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loadingMurid
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedMuridId,
                      decoration: _inputStyle('Pilih Murid', Icons.person),
                      items: _muridList
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.nama),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMuridId = v),
                      validator: (v) => v == null ? 'Murid harus dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _surahCtrl,
                      decoration: _inputStyle('Nama Surah', Icons.menu_book),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib isi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ayatMulaiCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputStyle('Ayat Mulai', Icons.format_list_numbered),
                            validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ayatSelesaiCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputStyle('Ayat Selesai', Icons.check_circle_outline),
                            validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedNote,
                      decoration: _inputStyle('Jenis', Icons.category_outlined),
                      items: const [
                        DropdownMenuItem(value: 'ziyadah', child: Text('Ziyadah')),
                        DropdownMenuItem(value: 'murajaah', child: Text("Muraja'ah")),
                      ],
                      onChanged: (v) => setState(() => _selectedNote = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 3,
                      decoration: _inputStyle('Catatan (Opsional)', Icons.edit_note),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _simpanMutabaah,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SIMPAN MUTABA\'AH'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
