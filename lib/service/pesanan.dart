import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/token.dart';

class PesananService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<Map<String, dynamic>> createPesanan(
      String orderId, List<CartItem> items) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse("$baseUrl/pesanan/");

    final payload = {
      "orderId": orderId,
      "items": items
          .map((item) => {
                "produkId": item.produk.id,
                "jumlah": item.jumlah,
              })
          .toList()
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    final result = jsonDecode(response.body);
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createPesanan(orderId, items);
    }
    if (response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result['message'] ?? 'Gagal membuat pesanan');
    }
  }

  Future<List<dynamic>> getPesananUser() async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pesanan/user');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getPesananUser();
    }
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['data'];
    } else {
      throw Exception("Gagal memuat pesanan");
    }
  }

  Future<Map<String, dynamic>> getPesananByTokoId(String id) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pesanan/toko/$id');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    print("Status code: ${response.statusCode}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getPesananByTokoId(id);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Gagal memuat pesanannnn");
    }
  }

  Future<Map<String, dynamic>> putStatusPesanan(
      String pesananId, String status) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pesanan/status');

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "pesananId": pesananId,
        "status": status,
      }),
    );
    print("Response body: ${response.body}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return putStatusPesanan(pesananId, status);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal memuat pesanan");
    }
  }

  Future<Map<String, dynamic>> createBuktiPengambilan(
      String pesananId, String image) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pesanan/bukti');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "pesananId": pesananId,
        "buktiDiterima": image,
      }),
    );
    print("Status code: ${response.statusCode}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createBuktiPengambilan(pesananId, image);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Gagal memuat pesanan");
    }
  }

  Future<Map<String, dynamic>> addPendapatan(
      String pesananId, int jumlahPendapatan) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pendapatan/');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "pesananId": pesananId,
        "jumlahPendapatan": jumlahPendapatan,
      }),
    );

    print("Status code: ${response.statusCode}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return addPendapatan(pesananId, jumlahPendapatan);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Gagal memuat pesanan");
    }
  }

  Future<Map<String, dynamic>> getPendapatanByPesananId(String id) async {
    final token = await tokenService().getAccessToken();
    final url = Uri.parse('$baseUrl/pesanan/id/$id');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    print("Status code: ${response.statusCode}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getPendapatanByPesananId(id);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Gagal memuat pendapatan");
    }
  }
}
