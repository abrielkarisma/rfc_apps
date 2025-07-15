import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/service/token.dart';

class SaldoService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store/saldo';

  Future<Map<String, dynamic>> getMySaldo() async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/user'); 
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getMySaldo();
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseBody['data'] != null) {
        return responseBody['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Data saldo tidak ditemukan di respons meskipun status 200');
      }
    } else {
      throw Exception(responseBody['message'] ?? 'Gagal mengambil saldo');
    }
  }

  Future<Map<String, dynamic>> getMyMutasiSaldo(
      {int page = 1, int limit = 10}) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/mutasi?page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getMyMutasiSaldo(page: page, limit: limit);
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody as Map<String, dynamic>;
    } else {
      throw Exception(
          responseBody['message'] ?? 'Gagal mengambil riwayat mutasi saldo');
    }
  }

  Future<Map<String, dynamic>> createPenarikanSaldo({
    required double jumlahDiminta,
  }) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/tarik-saldo');

    final Map<String, dynamic> payload = {
      'jumlahDiminta': jumlahDiminta,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createPenarikanSaldo(jumlahDiminta: jumlahDiminta);
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody['data'] as Map<String, dynamic>;
    } else {
      throw Exception(responseBody['message'] ??
          'Gagal membuat permintaan penarikan saldo');
    }
  }

  Future<Map<String, dynamic>> getMyPenarikanSaldoHistory(
      {int page = 1, int limit = 10}) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/histori-penarikan?page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getMyPenarikanSaldoHistory(page: page, limit: limit);
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody as Map<String, dynamic>;
    } else {
      throw Exception(
          responseBody['message'] ?? 'Gagal mengambil riwayat penarikan saldo');
    }
  }

  Future<Map<String, dynamic>> getAllPenarikanSaldoRequests({
    String status = 'pending',
    int page = 1,
    int limit = 10,
  }) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse(
        '$baseUrl/admin/request-penarikan?status=$status&page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );


    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getAllPenarikanSaldoRequests(
          status: status, page: page, limit: limit);
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody as Map<String, dynamic>;
    } else {
      throw Exception(responseBody['message'] ??
          'Gagal mengambil daftar permintaan penarikan');
    }
  }

  Future<Map<String, dynamic>> prosesPenarikanSaldo({
    required String penarikanId,
    required String status,
    String? catatanAdmin,
    String? buktiTransfer,
    String? referensiBank,
  }) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/admin/proses-penarikan/$penarikanId');

    final Map<String, dynamic> payload = {
      'status': status,
      if (catatanAdmin != null) 'catatanAdmin': catatanAdmin,
      if (buktiTransfer != null) 'buktiTransfer': buktiTransfer,
      if (referensiBank != null) 'referensiBank': referensiBank,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return prosesPenarikanSaldo(
        // Retry
        penarikanId: penarikanId,
        status: status,
        catatanAdmin: catatanAdmin,
        buktiTransfer: buktiTransfer,
        referensiBank: referensiBank,
      );
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody['data'] as Map<String, dynamic>;
    } else {
      throw Exception(responseBody['message'] ??
          'Gagal memproses permintaan penarikan saldo');
    }
  }

  
}
