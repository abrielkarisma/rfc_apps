import 'package:rfc_apps/model/komoditas.dart';

class KomoditasResponse {
  final String message;
  final List<KomoditasData> data;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  KomoditasResponse({
    required this.message,
    required this.data,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory KomoditasResponse.fromJson(Map<String, dynamic> json) {
    return KomoditasResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => KomoditasData.fromJson(item))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
    );
  }
}
