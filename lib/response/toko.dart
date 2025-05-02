import 'package:rfc_apps/model/toko.dart';

class TokoResponse {
  String? message;
  TokoData? data;

  TokoResponse({this.message, this.data});

  TokoResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? TokoData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
