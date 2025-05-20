import 'package:rfc_apps/model/keranjang.dart';

class CartResponse {
  final String message;
  final List<CartItem> data;

  CartResponse({
    required this.message,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}
