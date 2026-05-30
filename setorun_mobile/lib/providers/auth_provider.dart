import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/halaqoh_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._storage);

  final AuthService _authService;
  final StorageService _storage;

  AuthStatus status = AuthStatus.initial;
  UserModel? user;
  String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  Future<void> initialize() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      user = await _authService.restoreSession();
      status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      await _storage.clearSession();
      status = AuthStatus.unauthenticated;
      user = null;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      user = await _authService.login(email: email, password: password);
    });
  }

  Future<bool> registerStudent({
    required String email,
    required String fullName,
    required String gender,
    required String password,
    required String passwordConfirm,
    required int halaqohId,
  }) async {
    return _runAuthAction(() async {
      user = await _authService.registerStudent(
        email: email,
        fullName: fullName,
        gender: gender,
        password: password,
        passwordConfirm: passwordConfirm,
        halaqohId: halaqohId,
      );
    });
  }

  Future<List<HalaqohModel>> loadHalaqohList() {
    return _authService.fetchHalaqohList();
  }

  Future<void> refreshProfile() async {
    if (!await _storage.hasSession()) return;
    try {
      user = await _authService.fetchProfile();
      notifyListeners();
    } on DioException {
      // Abaikan error refresh ringan.
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? gender,
  }) async {
    try {
      user = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        gender: gender,
      );
      notifyListeners();
      return true;
    } on DioException catch (e) {
      errorMessage = _authService.parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      errorMessage = _authService.parseError(e);
      status = AuthStatus.unauthenticated;
      user = null;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.unauthenticated;
      user = null;
      notifyListeners();
      return false;
    }
  }
}
