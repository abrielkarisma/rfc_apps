import 'package:rfc_apps/model/toko.dart';

class TokoResponse {
  String? message;
  final List<TokoData> data;

  TokoResponse({this.message, required this.data});

 factory TokoResponse.fromJson(Map<String, dynamic> json) {
    return TokoResponse(
      message: json['message'],
      data: (json['data'] as List).map((item) => TokoData.fromJson(item)).toList(),
    );
  }
}
