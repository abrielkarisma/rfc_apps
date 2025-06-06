import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/response/rekening.dart';
import 'package:rfc_apps/service/token.dart';

class rekeningService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<RekeningResponse> getRekeningByUserId() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/rekening/user'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getRekeningByUserId();
    }
    if (response.statusCode == 200) {
      print(response.body);
      return RekeningResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Rekening data');
    }
  }
Future<Map<String, dynamic>?> getRekeningBytoken() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/rekening/user'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getRekeningBytoken();
    }
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseBody['data'] != null) {
        return responseBody['data'] as Map<String, dynamic>;
      } else {
        return null; 
      }
    } else if (response.statusCode == 404) {
        return null; 
    } else {
      throw Exception(responseBody['message'] ?? 'Gagal mengambil data rekening aktif');
    }
  }
  Future<Map<String, dynamic>> CreateRekening(
      String namaPenerima, String namaBank, String nomorRekening) async {
    final token = await tokenService().getAccessToken();
    final response = await http.post(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/rekening/'),
      body: jsonEncode({
        'nomorRekening': nomorRekening,
        'namaBank': namaBank,
        'namaPenerima': namaPenerima,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return CreateRekening(namaPenerima, namaBank, nomorRekening);
    }
    if (response.statusCode == 201) {
      print(response.body);
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create rekening data');
    }
  }

  Future<Map<String, dynamic>> updateRekening(
      String id, String namaPenerima, String namaBank, String noRek) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/rekening/$id'),
      body: jsonEncode({
        'nomorRekening': noRek,
        'namaBank': namaBank,
        'namaPenerima': namaPenerima,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return updateRekening(id, namaPenerima, namaBank, noRek);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update rekening data');
    }
  }
}
