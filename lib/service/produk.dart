import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/response/produk.dart';
import 'package:rfc_apps/service/token.dart';

class ProdukService {
  String baseUrl = '${dotenv.env["BASE_URL"]}store';

  Future<Map<String, dynamic>> createProduk(
    String namaProduk,
    String harga,
    String stok,
    String satuan,
    String deskripsi,
    String gambarProduk,
  ) async {
    final token = await tokenService().getAccessToken();

    final response = await http.post(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk'),
      body: jsonEncode({
        'nama': namaProduk,
        'harga': harga,
        'stok': stok,
        'satuan': satuan,
        'deskripsi': deskripsi,
        'gambar': gambarProduk,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createProduk(
        namaProduk,
        harga,
        stok,
        satuan,
        deskripsi,
        gambarProduk,
      );
    }
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create produk data');
    }
  }

  Future<Map<String, dynamic>> createProductByKomoditas(
    String komoditasId,
    String namaProduk,
    String harga,
    String stok,
    String satuan,
    String deskripsi,
    String gambarProduk,
  ) async {
    final token = await tokenService().getAccessToken();

    final response = await http.post(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/komoditas'),
      body: jsonEncode({
        'komoditasId': komoditasId,
        'nama': namaProduk,
        'harga': harga,
        'stok': stok,
        'satuan': satuan,
        'deskripsi': deskripsi,
        'gambar': gambarProduk,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createProduk(
        namaProduk,
        harga,
        stok,
        satuan,
        deskripsi,
        gambarProduk,
      );
    }
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create produk data');
    }
  }

  Future<List<Produk>> getProdukByTokoId(String Id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/idToko/$Id'),
    );

    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getProdukByTokoId(Id);
    }
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      final List<dynamic> data = responseData['data'];
      final filteredData =
          data.where((item) => item['isDeleted'] == false).toList();
      return filteredData.map((item) => Produk.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load produk data');
    }
  }

  Future<List<Produk>> getProdukByUserId() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/token'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getProdukByUserId();
    }
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      final filteredData =
          data.where((item) => item['isDeleted'] == false).toList();
      return filteredData.map((item) => Produk.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load produk data');
    }
  }

  Future<ProdukResponse> getProdukById(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/id/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getProdukById(id);
    }
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load produk data');
    }
  }

  Future<List<Produk>> getRFCProduk() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/rfc'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getRFCProduk();
    }
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      final filteredData =
          data.where((item) => item['isDeleted'] == false).toList();
      return filteredData.map((item) => Produk.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load produk data');
    }
  }

  Future<List<Produk>> getUMKMProduk() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/umkm'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getRFCProduk();
    }
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];
      final filteredData =
          data.where((item) => item['isDeleted'] == false).toList();
      return filteredData.map((item) => Produk.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load produk data');
    }
  }

  Future<ProdukResponse> updateProduk(
    String id,
    String namaProduk,
    String harga,
    String stok,
    String satuan,
    String deskripsi,
    String gambarProduk,
  ) async {
    final token = await tokenService().getAccessToken();
    final response = await http.put(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/id/$id'),
      body: jsonEncode({
        'nama': namaProduk,
        'harga': harga,
        'stok': stok,
        'satuan': satuan,
        'deskripsi': deskripsi,
        'gambar': gambarProduk,
      }),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return updateProduk(
        id,
        namaProduk,
        harga,
        stok,
        satuan,
        deskripsi,
        gambarProduk,
      );
    }
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update produk data');
    }
  }

  Future<ProdukResponse> deleteProduk(String id) async {
    final token = await tokenService().getAccessToken();
    final response = await http.delete(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/$id'),
    );
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return deleteProduk(id);
    }
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete produk dataaaaaaa');
    }
  }

  Future<Map<String, dynamic>> getProdukStok(String id) async {
    final token = await tokenService().getAccessToken();

    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      Uri.parse('$baseUrl/produk/stok/$id'),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return getProdukStok(id);
    }

    if (response.statusCode == 200 || response.statusCode == 404) {
      return jsonDecode(response.body); // ⬅️ Kembalikan Map
    } else {
      throw Exception('Failed to get stok produk');
    }
  }
}
