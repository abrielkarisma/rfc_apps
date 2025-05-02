import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/response/produk.dart';
import 'package:rfc_apps/service/token.dart';

class ProdukService {
  String baseUrl = 'http://10.0.2.2:4000/api/store';

  Future<ProdukResponse> createProduk(
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
      print(response.body + "akay");
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create produk data');
    }
  }

  Future<List<Produk>> getProdukByUserId() async {
    final token = await tokenService().getAccessToken();
    final response = await http.get(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      Uri.parse('$baseUrl/produk/toko'),
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
    // print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete produk data');
    }
  }
}
