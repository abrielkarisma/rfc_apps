import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/response/user.dart';

class UserService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}';

  Future<UserResponse> getUserById(String id) async {
    final response = await http.get(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/user/id/$id'),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<UserResponse> UpdateUser(
      String id, String name, String avatarUrl) async {
    final response = await http.put(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/user/$id'),
      body: jsonEncode({
        'name': name,
        'avatarUrl': avatarUrl,
      }),
    );
    final result = UserResponse.fromJson(jsonDecode(response.body));
    if (result.message == 'Successfully updated user data') {
      print(response.body);
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user data');
    }
  }

  Future<Map<String, dynamic>> getAllPenjual() async {
    final response = await http.get(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/user/seller'),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load penjual data');
    }
  }

  Future<Map<String, dynamic>> getAllPenjualById(String id) async {
    final response = await http.get(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/user/seller/$id'),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load penjual data');
    }
  }
}
