import 'package:flutter/material.dart';

class FillMutabaahScreen extends StatefulWidget {
  const FillMutabaahScreen({super.key});

  @override
  State<FillMutabaahScreen> createState() => _FillMutabaahScreenState();
}

class _FillMutabaahScreenState extends State<FillMutabaahScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variabel untuk menyimpan inputan form
  String? _selectedMurid;
  String? _selectedSurah;
  final TextEditingController _ayatMulaiCtrl = TextEditingController();
  final TextEditingController _ayatSelesaiCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();
  double _nilaiKualitas = 80.0; // Slider nilai

  // Dummy data untuk dropdown
  final List<String> _daftarMurid = ['Nadia Qurrotu', 'Zunaizah', 'Ulyatul Faizah', 'Ahmad', 'Fatimah'];
  final List<String> _daftarSurah = ['An-Naba', 'An-Naziat', 'Abasa', 'At-Takwir', 'Al-Infitar'];

  @override
  void dispose() {
    _ayatMulaiCtrl.dispose();
    _ayatSelesaiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _simpanMutabaah() {
    if (_formKey.currentState!.validate()) {
      // Jika form valid, kita simulasikan penyimpanan data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alhamdulillah, Mutaba\'ah berhasil disimpan!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke dashboard setelah 1 detik
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Tanggal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      'Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pilih Murid
              DropdownButtonFormField<String>(
                decoration: _inputStyle('Pilih Murid', Icons.person),
                items: _daftarMurid.map((murid) => DropdownMenuItem(value: murid, child: Text(murid))).toList(),
                onChanged: (val) => setState(() => _selectedMurid = val),
                validator: (value) => value == null ? 'Murid harus dipilih' : null,
              ),
              const SizedBox(height: 16),

              // Pilih Surah
              DropdownButtonFormField<String>(
                decoration: _inputStyle('Surah', Icons.menu_book),
                items: _daftarSurah.map((surah) => DropdownMenuItem(value: surah, child: Text(surah))).toList(),
                onChanged: (val) => setState(() => _selectedSurah = val),
                validator: (value) => value == null ? 'Surah harus dipilih' : null,
              ),
              const SizedBox(height: 16),

              // Ayat Mulai & Selesai (Row)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ayatMulaiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle('Ayat Mulai', Icons.format_list_numbered),
                      validator: (value) => value!.isEmpty ? 'Wajib isi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ayatSelesaiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle('Ayat Selesai', Icons.check_circle_outline),
                      validator: (value) => value!.isEmpty ? 'Wajib isi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kualitas Hafalan (Slider)
              const Text('Kualitas Kelancaran & Tajwid:', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _nilaiKualitas,
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: Colors.teal,
                label: _nilaiKualitas.round().toString(),
                onChanged: (val) => setState(() => _nilaiKualitas = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mengulang', style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
                  Text('Sangat Lancar', style: TextStyle(color: Colors.teal.shade700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),

              // Catatan Guru
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 3,
                decoration: _inputStyle('Catatan Khusus (Opsional)', Icons.edit_note),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanMutabaah,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SIMPAN MUTABA\'AH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi bantuan untuk style input agar seragam
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}