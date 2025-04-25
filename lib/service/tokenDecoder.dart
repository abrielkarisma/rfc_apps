import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:rfc_apps/response/user.dart';

final _storage = FlutterSecureStorage();

Future<Map<String, dynamic>> decodeToken() async {
  final token = await _storage.read(key: 'token');
  if (token == null) {
    throw Exception('Token not found');
  }
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid token format');
  }
  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final Map<String, dynamic> payloadMap = json.decode(payload);
  return payloadMap;
}

Future<String?> getUserId() async {
  final tokenData = await decodeToken();
  return tokenData['id'];
}
