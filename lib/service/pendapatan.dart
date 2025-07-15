import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/service/token.dart';

class PendapatanService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store';
  Future<Map<String, dynamic>> getPendapatan(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/pendapatan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getPendapatan(id);
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat pendapatannnnn');
    }
  }
}
