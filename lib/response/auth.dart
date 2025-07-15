import 'package:rfc_apps/model/user.dart';

class AuthResponse {
  final bool status;
  final String message;
  final User? data;
  final String? token;
  final String? refreshToken;

    AuthResponse({
    required this.status,
    required this.message,
    this.data,
    this.token,
    this.refreshToken,
  });


  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json.containsKey('data'), 
      message: json['message'] ?? '',
      data: json['data'] != null ? User.fromJson(json['data']) : null,
      token: json['token'] ?? "",
      refreshToken: json['refreshToken'] ?? "",
    );
  }
}
