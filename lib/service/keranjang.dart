import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/token.dart';

class KeranjangService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<List<CartItem>> getAllKeranjang() async {
    final token = await tokenService().getAccessToken();

    final response = await http.get(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }, Uri.parse('$baseUrl/keranjang/id/'));
    print(jsonDecode(response.body));
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getAllKeranjang();
    }
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List items = jsonData['data'];
      return items.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data keranjang');
    }
  }

  Future<Map<String, dynamic>> createKeranjang(
      String produkId, int jumlah) async {
    final token = await tokenService().getAccessToken();
    final response = await http.post(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      Uri.parse('$baseUrl/keranjang/'),
      body: jsonEncode({
        'produkId': produkId,
        'jumlah': jumlah,
      }),
    );
    print(produkId);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createKeranjang(produkId, jumlah);
    }
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menambahkan produk ke keranjang');
    }
  }

  Future<Map<String, dynamic>> updateKeranjang(String id, int jumlah) async {
    final token = await tokenService().getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl/keranjang/id/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'jumlah': jumlah}),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return updateKeranjang(id, jumlah);
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memperbarui jumlah keranjang');
    }
  }

  Future<void> deleteKeranjang(String id) async {
    final token = await tokenService().getAccessToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/keranjang/id/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('DELETE ID: $id');
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return deleteKeranjang(id);
    }

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus item keranjang');
    }
  }

}
