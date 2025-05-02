import '../model/rekening.dart';

class RekeningResponse {
  String? message;
  Rekening? data;

  RekeningResponse({
    required this.message,
    required this.data,
  });

  RekeningResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Rekening.fromJson(json['data']) : null;
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
