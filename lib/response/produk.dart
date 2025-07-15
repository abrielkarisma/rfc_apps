import 'package:rfc_apps/model/produk.dart' show Produk;
import 'package:rfc_apps/view/pembeli/homepage/produk/produk.dart';

class ProdukResponse {
  final String message;
  final List<Produk> data;

  ProdukResponse({required this.message, required this.data});

  factory ProdukResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    if (rawData is List) {
      List<Produk> produkList =
          rawData.map((item) => Produk.fromJson(item)).toList();

      return ProdukResponse(
        message: json['message'],
        data: produkList,
      );
    } else if (rawData is Map<String, dynamic>) {
      
      return ProdukResponse(
        message: json['message'],
        data: [Produk.fromJson(rawData)],
      );
    } else {
      throw Exception('Unexpected data format: ${rawData.runtimeType}');
    }
  }
}
