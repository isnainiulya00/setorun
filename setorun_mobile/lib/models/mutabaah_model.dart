class MutabaahModel {
  final int id;
  final int muridId;
  final String muridNama;
  final DateTime? tanggal;
  final String namaSurah;
  final String ayat;
  final String note;
  final String noteDisplay;
  final String? keterangan;
  final String judul;
  final String status;

  const MutabaahModel({
    required this.id,
    required this.muridId,
    required this.muridNama,
    this.tanggal,
    required this.namaSurah,
    required this.ayat,
    required this.note,
    required this.noteDisplay,
    this.keterangan,
    required this.judul,
    required this.status,
  });

  factory MutabaahModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final raw = json['tanggal'];
    if (raw is String) {
      parsedDate = DateTime.tryParse(raw);
    }

    return MutabaahModel(
      id: json['id'] as int,
      muridId: json['murid'] as int,
      muridNama: json['murid_nama'] as String? ?? '',
      tanggal: parsedDate,
      namaSurah: json['nama_surah'] as String? ?? '',
      ayat: json['ayat'] as String? ?? '',
      note: json['note'] as String? ?? '',
      noteDisplay: json['note_display'] as String? ?? '',
      keterangan: json['keterangan'] as String?,
      judul: json['judul'] as String? ?? '',
      status: json['status'] as String? ?? 'Selesai',
    );
  }

  String get tanggalLabel {
    if (tanggal == null) return '';
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${days[tanggal!.weekday - 1]}, ${tanggal!.day}/${tanggal!.month}/${tanggal!.year}';
  }
}
