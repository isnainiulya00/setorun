class HalaqohModel {
  final int id;
  final String name;
  final String gender;
  final String? guruName;

  const HalaqohModel({
    required this.id,
    required this.name,
    required this.gender,
    this.guruName,
  });

  factory HalaqohModel.fromJson(Map<String, dynamic> json) {
    return HalaqohModel(
      id: json['id'] as int,
      name: (json['name'] ?? json['nama']) as String? ?? '',
      gender: json['gender'] as String? ?? '',
      guruName: json['guru_name'] as String?,
    );
  }
}
