// File: lib/service/midtrans_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/token.dart';

class MidtransService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}store';
  Future<Map<String, dynamic>> createTransaction(
      String orderId, List<CartItem> items) async {
    final token = await tokenService().getAccessToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/midtrans/transaction"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'items': items
              .map((e) => {
                    'id': e.produk.id,
                    'jumlah': e.jumlah,
                  })
              .toList(),
        }),
      );
      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return createTransaction(orderId, items);
      }
      // print(response.body);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Gagal membuat transaksi';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransactionStatus(String orderId) async {
    final token = await tokenService().getAccessToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/midtrans/transaction/status/$orderId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return getTransactionStatus(orderId);
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mendapatkan status transaksi');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTransactionForPesanan(
      String orderId, String pesananId) async {
    final token = await tokenService().getAccessToken();
    final response = await http.post(
      Uri.parse("$baseUrl/midtrans/transaction/recreate"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'orderId': orderId, 'pesananId': pesananId}),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 401) {
      await tokenService().refreshToken();
      return createTransactionForPesanan(orderId, pesananId);
    }
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal membuat transaksi ulang');
    }
  }
}
