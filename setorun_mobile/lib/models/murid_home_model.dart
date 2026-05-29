import 'mutabaah_model.dart';

class MuridHomeModel {
  final String nama;
  final String halaqohNama;
  final String guruNama;
  final String jadwal;
  final int progressPercent;
  final List<MutabaahModel> riwayat;

  const MuridHomeModel({
    required this.nama,
    required this.halaqohNama,
    required this.guruNama,
    required this.jadwal,
    required this.progressPercent,
    required this.riwayat,
  });

  factory MuridHomeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['riwayat'];
    final list = raw is List
        ? raw
            .map((e) => MutabaahModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MutabaahModel>[];

    return MuridHomeModel(
      nama: json['nama'] as String? ?? '',
      halaqohNama: json['halaqoh_nama'] as String? ?? '',
      guruNama: json['guru_nama'] as String? ?? '',
      jadwal: json['jadwal'] as String? ?? '',
      progressPercent: json['progress_percent'] as int? ?? 0,
      riwayat: list,
    );
  }
}
