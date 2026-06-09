import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 10.141.128.3500/api,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // --- LOGIKA PENGECUALIAN ---
          // Kita cek apakah path request adalah login atau register
          final isAuthEndpoint = options.path.contains('/auth/login/') || 
                                options.path.contains('/auth/register/');

          if (isAuthEndpoint) {
            print('🔓 AKSES BEBAS: Menuju endpoint autentikasi, tanpa token.');
            return handler.next(options);
          }
          // ---------------------------

          final token = await _storage.getAccessToken();
          
          print('====================================');
          print('🚀 MENGIRIM REQUEST KE: ${options.path}');
          
          if (token != null && token.isNotEmpty) {
            print('🔑 TOKEN DITEMUKAN: Menyematkan token ke header.');
            options.headers['Authorization'] = 'Bearer $token'; 
          } else {
            print('⚠️ PERINGATAN: Token Kosong!');
          }
          print('====================================');

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('🔴 API DITOLAK [${e.response?.statusCode}] PADA: ${e.requestOptions.path}');
          return handler.next(e);
        }
      ),
    );
  }

  final StorageService _storage;
  late final Dio _dio;

  Dio get dio => _dio;
}