import 'package:dio/dio.dart';

import '../models/halaqoh_model.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._api, this._storage);

  final ApiClient _api;
  final StorageService _storage;

  Future<List<HalaqohModel>> fetchHalaqohList() async {
    final response = await _api.dio.get('/halaqoh/');
    final data = response.data;
    if (data is! List) return [];
    return data
        .map((item) => HalaqohModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.dio.post(
      '/auth/login/',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    return _persistAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<UserModel> registerStudent({
    required String email,
    required String fullName,
    required String gender,
    required String password,
    required String passwordConfirm,
    required int halaqohId,
  }) async {
    final response = await _api.dio.post(
      '/auth/register/',
      data: {
        'email': email.trim().toLowerCase(),
        'full_name': fullName.trim(),
        'gender': gender,
        'password': password,
        'password_confirm': passwordConfirm,
        'halaqoh_id': halaqohId,
      },
    );
    return _persistAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<UserModel> fetchProfile() async {
    final response = await _api.dio.get('/auth/profile/');
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    await _storage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout/');
    } on DioException {
      // Token mungkin sudah invalid; tetap bersihkan session lokal.
    }
    await _storage.clearSession();
  }

  Future<UserModel?> restoreSession() async {
    if (!await _storage.hasSession()) return null;
    try {
      return await fetchProfile();
    } on DioException {
      await _storage.clearSession();
      return null;
    }
  }

  Future<UserModel> _persistAuthResponse(Map<String, dynamic> data) async {
    final access = data['access'] as String;
    final refresh = data['refresh'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveTokens(accessToken: access, refreshToken: refresh);
    await _storage.saveUser(user);
    return user;
  }

  String parseError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) return data['detail'].toString();
      final messages = <String>[];
      data.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          messages.add('${value.first}');
        } else if (value is String) {
          messages.add(value);
        }
      });
      if (messages.isNotEmpty) return messages.join('\n');
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend Django berjalan.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
