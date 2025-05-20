import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rfc_apps/response/user.dart';

class tokenService {
  final _storage = FlutterSecureStorage();
  final String baseUrl = '${dotenv.env["BASE_URL"]}auth';

  Future<Map<String, dynamic>> decodeToken() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token not found');
    }
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> payloadMap = json.decode(payload);
    return payloadMap;
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'token');
    return token;
  }

  Future<String?> getUserId() async {
    final tokenData = await decodeToken();
    return tokenData['id'];
  }

  Future<void> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    print(refreshToken);

    final response = await http.get(
      Uri.parse('$baseUrl/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    } else {
      throw Exception(data);
    }
  }
}
