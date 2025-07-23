import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/toko.dart';
import 'package:rfc_apps/response/toko.dart';
import 'package:rfc_apps/service/token.dart';

class tokoService {
  String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<Map<String, dynamic>> createToko(String nama, String phone,
      String alamat, String logoToko, String deskripsi) async {
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
    final result = jsonDecode(response.body);
    return result;
  }

  Future<List<TokoData>> getToko() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      Uri.parse('$baseUrl/toko/'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getToko();
    }
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      final filteredData =
          data.where((item) => item['isDeleted'] == false).toList();
      return filteredData.map((item) => TokoData.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return TokoResponse.fromJson(jsonDecode(response.body)).data;
    } else {
      throw Exception('Failed to load toko data');
    }
  }

  Future<TokoResponse> getTokoById(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      Uri.parse('$baseUrl/toko/id/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getTokoById(id);
    }
    if (response.statusCode == 200) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return TokoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load toko data');
    }
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

  Future<TokoResponse> getTokoByIdUser(String id) async {
    final token = await tokenService().getAccessToken();

    final response = await http.get(
      headers: {
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/idUser/$id'),
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

  Future<Map<String, dynamic>> UpdateToko(String id, String name, String phone,
      String alamat, String avatarUrl, String deskripsi) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/$id'),
      body: jsonEncode({
        'nama': name,
        'phone': phone,
        'alamat': alamat,
        'logoToko': avatarUrl,
        'deskripsi': deskripsi,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return UpdateToko(id, name, phone, alamat, avatarUrl, deskripsi);
    }
    if (response.statusCode == 404) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update toko data');
    }
  }

  Future<Map<String, dynamic>> UpdateTokoGambar(
      String id, String avatarUrl) async {
    final token = await tokenService().getAccessToken();
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
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return UpdateTokoGambar(id, avatarUrl);
    }
    if (response.statusCode == 404) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update toko data');
    }
  }

  Future<Map<String, dynamic>> deleteToko(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/ban/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return deleteToko(id);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete toko data');
    }
  }

  Future<Map<String, dynamic>> activateToko(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/activate/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return activateToko(id);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete toko data');
    }
  }

  Future<Map<String, dynamic>> rejectToko(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/toko/reject/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return activateToko(id);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete toko data');
    }
  }
}
