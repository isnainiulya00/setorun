import 'package:dio/dio.dart';

import '../models/murid_brief_model.dart';
import '../models/murid_home_model.dart';
import '../models/mutabaah_model.dart';
import 'api_client.dart';

class MutabaahService {
  MutabaahService(this._api);

  final ApiClient _api;

  Future<List<MutabaahModel>> fetchList() async {
    final response = await _api.dio.get('/mutabaah/');
    final data = response.data;
    if (data is! List) return [];
    return data
        .map((e) => MutabaahModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MutabaahModel> create({
    required int muridId,
    required String namaSurah,
    required int ayatMulai,
    required int ayatSelesai,
    required String note,
    String? keterangan,
  }) async {
    final response = await _api.dio.post(
      '/mutabaah/',
      data: {
        'murid': muridId,
        'nama_surah': namaSurah,
        'ayat_mulai': ayatMulai,
        'ayat_selesai': ayatSelesai,
        'note': note,
        if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
      },
    );
    return MutabaahModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.dio.delete('/mutabaah/$id/');
  }
}

class HomeService {
  HomeService(this._api);

  final ApiClient _api;

  Future<MuridHomeModel> fetchMuridHome() async {
    final response = await _api.dio.get('/home/murid/');
    return MuridHomeModel.fromJson(response.data as Map<String, dynamic>);
  }
}

class MuridService {
  MuridService(this._api);

  final ApiClient _api;

  Future<List<MuridBriefModel>> fetchMuridList() async {
    final response = await _api.dio.get('/murid/');
    final data = response.data;
    if (data is! List) return [];
    return data
        .map((e) => MuridBriefModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
