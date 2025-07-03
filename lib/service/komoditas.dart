import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/response/komoditas.dart';
import 'package:rfc_apps/service/token.dart';

class KomoditasService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}farm';

  Future<KomoditasResponse> getUnproductKomoditas() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/komoditas/unproduct'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getUnproductKomoditas();
    }

    if (response.statusCode == 200) {
      return KomoditasResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load komoditas');
    }
  }

  Future<KomoditasResponse> getKomoditasById(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/komoditas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getKomoditasById(id);
    }

    if (response.statusCode == 200) {
      return KomoditasResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load komoditas data');
    }
  }
}
