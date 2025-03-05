import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/user.dart';
import 'package:rfc_apps/response/auth.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000/auth';

  Future<AuthResponse> registerUser(User user, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': user.nama,
        'email': user.email,
        'nomor_telepon': user.nomorTelepon,
        'password': password,
        'role': user.role,
        'profile_picture': user.profilePicture,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<AuthResponse> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login user');
    }
  }

  Future<bool> checkEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkEmail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      throw Exception('Failed to check email');
    }
  }

  Future<bool> checkNomorTelepon(String nomorTelepon) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkNomor'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nomor_telepon': nomorTelepon}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      throw Exception('Failed to check phone number');
    }
  }
}
