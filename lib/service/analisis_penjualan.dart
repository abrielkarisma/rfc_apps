import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/service/token.dart';

class AnalisisPenjualanService {
  String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<Map<String, dynamic>> getProdukTerjual(String tokoId,
      {int? bulan, int? tahun}) async {
    final token = await tokenService().getAccessToken();

    String endpoint = '$baseUrl/pesanan/toko/$tokoId/selesai';
    if (bulan != null && tahun != null) {
      endpoint += '?bulan=$bulan&tahun=$tahun';
    }

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getProdukTerjual(tokoId, bulan: bulan, tahun: tahun);
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load produk terjual: ${response.body}');
    }
  }

  // Get available months
  Future<Map<String, dynamic>> getAvailableMonths(String tokoId) async {
    final token = await tokenService().getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/pesanan/toko/bulan/$tokoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getAvailableMonths(tokoId);
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load available months: ${response.body}');
    }
  }
}
