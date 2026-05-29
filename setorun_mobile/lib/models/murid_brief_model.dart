class MuridBriefModel {
  final int id;
  final String nama;
  final String email;
  final String gender;

  const MuridBriefModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.gender,
  });

  factory MuridBriefModel.fromJson(Map<String, dynamic> json) {
    return MuridBriefModel(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
    );
  }
}
