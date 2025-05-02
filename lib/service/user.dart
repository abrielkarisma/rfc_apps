import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rfc_apps/response/user.dart';

class UserService {
  final String baseUrl = 'http://10.0.2.2:4000/api/';

  Future<UserResponse> getUserById(String id) async {
    final response = await http.get(
      headers: {'Content-Type': 'application/json'},
      Uri.parse('$baseUrl/user/$id'),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<UserResponse> UpdateUser(String id, String name, String avatarUrl) async {
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
}
