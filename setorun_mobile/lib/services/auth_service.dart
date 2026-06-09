import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/halaqoh_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._api, this._storage);

  final ApiClient _api;
  final StorageService _storage;

  // ==========================================
  // 1. RESTORE SESSION 
  // ==========================================
  Future<UserModel?> restoreSession() async {
    if (!await _storage.hasSession()) return null;
    try {
      return await fetchProfile();
    } catch (_) {
      await _storage.clearSession();
      return null;
    }
  }

  // ==========================================
  // 2. LOGIN (Sudah diperbaiki!)
  // ==========================================
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.dio.post('auth/login/', data: {
      'login': email,
      'password': password,
    });

    final data = response.data;
    
    // Simpan token dengan nama fungsi yang benar!
    final accessToken = data['access'];
    final refreshToken = data['refresh'];
    await _storage.saveTokens(
      accessToken: accessToken, 
      refreshToken: refreshToken
    );

    // Sekalian kita simpan data user-nya biar aplikasinya nggak bingung
    final user = UserModel.fromJson(data['user']);
    await _storage.saveUser(user);

    return user;
  }

  // ==========================================
  // 3. REGISTER STUDENT (Sudah diperbaiki!)
  // ==========================================
  Future<UserModel> registerStudent({
    required String email,
    required String fullName,
    required String gender,
    required String password,
    required String passwordConfirm,
    required int halaqohId,
  }) async {
    final response = await _api.dio.post('/auth/register/student/', data: {
      'email': email,
      'nama': fullName,
      'gender': gender,
      'password': password,
      'halaqoh_id': halaqohId,
    });

    final data = response.data;

    // Simpan token dengan nama fungsi yang benar!
    if (data.containsKey('access') && data.containsKey('refresh')) {
      await _storage.saveTokens(
        accessToken: data['access'], 
        refreshToken: data['refresh']
      );
    }

    final user = UserModel.fromJson(data['user']);
    await _storage.saveUser(user);

    return user;
  }

  Future<List<HalaqohModel>> fetchHalaqohList() async {
    final response = await _api.dio.get('/halaqoh/'); 
    final List list = response.data;
    return list.map((e) => HalaqohModel.fromJson(e)).toList();
  }

  Future<UserModel> fetchProfile() async {
    final response = await _api.dio.get('/auth/profile/'); 
    final user = UserModel.fromJson(response.data);
    await _storage.saveUser(user); // Update data lokal
    return user;
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? gender,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['nama'] = fullName;
    if (email != null) data['email'] = email;
    if (gender != null) data['gender'] = gender;

    final response = await _api.dio.patch('/auth/profile/', data: data);
    final user = UserModel.fromJson(response.data);
    await _storage.saveUser(user); // Update data lokal
    return user;
  }

  // ==========================================
  // 7. LOGOUT
  // ==========================================
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout/');
    } catch (_) {}
    await _storage.clearSession();
  }

  // ==========================================
  // 8. PARSER ERROR
  // ==========================================
  String parseError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('detail')) return data['detail'];
      if (data.containsKey('error')) return data['error'];
      
      final firstKey = data.keys.first;
      if (data[firstKey] is List) {
         return data[firstKey][0].toString();
      }
    }
    return e.message ?? 'Terjadi kesalahan pada server';
  }
}