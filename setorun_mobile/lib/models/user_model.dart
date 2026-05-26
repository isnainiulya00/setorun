import 'halaqoh_model.dart';

class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String gender;
  final String role;
  final String roleDisplay;
  final int? halaqohId;
  final HalaqohModel? halaqoh;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.role,
    required this.roleDisplay,
    this.halaqohId,
    this.halaqoh,
  });

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';

  String get uiRole => isTeacher ? 'Guru' : 'Murid';

  String get genderLabel => gender == 'male' ? 'Laki-laki' : 'Perempuan';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    HalaqohModel? halaqoh;
    final halaqohDetail = json['halaqoh_detail'];
    if (halaqohDetail is Map<String, dynamic>) {
      halaqoh = HalaqohModel.fromJson(halaqohDetail);
    }

    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      fullName: (json['full_name'] ?? json['nama']) as String? ?? '',
      gender: json['gender'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      roleDisplay: json['role_display'] as String? ?? 'Murid',
      halaqohId: json['halaqoh'] as int?,
      halaqoh: halaqoh,
    );
  }
}
