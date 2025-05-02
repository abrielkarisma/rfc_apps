import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rfc_apps/response/toko.dart';
import 'package:rfc_apps/service/token.dart';

class tokoService {
  String baseUrl = 'http://10.0.2.2:4000/api/store';

  Future<TokoResponse> createToko(String nama, String phone, String alamat,
      String logoToko, String deskripsi) async {
    final token = await tokenService().getAccessToken();
    final response = await http.post(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      Uri.parse('$baseUrl/toko/'),
      body: jsonEncode({
        'nama': nama,
        'phone': phone,
        'alamat': alamat,
        'logoToko': logoToko,
        'deskripsi': deskripsi,
      }),
    );
    final result = TokoResponse.fromJson(jsonDecode(response.body));
    return result;
  }

  Future<TokoResponse> getTokoByUserId() async {
    final token = await tokenService().getAccessToken();

    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/user/'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getTokoByUserId();
    }
    if (response.statusCode == 200) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load toko data');
    }
  }

  Future<TokoResponse> getTokoById(String id) async {
    final response = await http.get(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/toko/id/$id'),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load toko data');
    }
  }

  Future<TokoResponse> UpdateToko(String id, String name, String phone,
      String alamat, String avatarUrl, String deskripsi) async {
    final token = await tokenService().getAccessToken();
    print(token);
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/$id'),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'alamat': alamat,
        'logoToko': avatarUrl,
        'deskripsi': deskripsi,
      }),
    );
    print(response.body);
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getTokoByUserId();
    }
    if (response.statusCode == 404) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 200) {
      print(response.body);
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update toko data');
    }
  }

  Future<TokoResponse> UpdateTokoGambar(String id, String avatarUrl) async {
    final token = await tokenService().getAccessToken();
    print(token);
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/$id'),
      body: jsonEncode({
        'logoToko': avatarUrl,
      }),
    );
    print(response.body);
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getTokoByUserId();
    }
    if (response.statusCode == 404) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 200) {
      print(response.body);
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update toko data');
    }
  }
}
