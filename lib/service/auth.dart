import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/user.dart';
import 'package:rfc_apps/response/auth.dart';
import 'package:rfc_apps/response/otp.dart';

class AuthService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}auth';

  Future<AuthResponse> registerUser(
      String name,
      String email,
      String phoneNumber,
      String password,
      String confirmPassword,
      String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      }),
    );
    print(name);
    print(jsonEncode(response.body));

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<AuthResponse> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final result = AuthResponse.fromJson(jsonDecode(response.body));
    if (result.status == true) {
      return AuthResponse(
        status: true,
        message: result.message,
        data: User(
          id: result.data?.id ?? '',
          name: result.data?.name ?? '',
          email: result.data?.email ?? '',
          phoneNumber: result.data?.phoneNumber ?? '',
          role: result.data?.role ?? '',
        ),
        token: result.token,
        refreshToken: result.refreshToken,
      );
    } else if (result.status == false) {
      return AuthResponse(
        status: false,
        message: result.message,
        data: null,
        token: null,
        refreshToken: null,
      );
    } else {
      return AuthResponse(
        status: false,
        message: 'Error',
        data: null,
      );
    }
  }

  Future<OtpResponse> verifyOtp(
      {required String phone_number, required String otp}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verifyPhone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone_number,
          'otp': otp,
        }),
      );

      final data = OtpResponse.fromJson(jsonDecode(response.body));
      if (data.status == true) {
        return OtpResponse(
          status: true,
          message: 'OTP berhasil diverifikasi',
          data: OtpData(
            id: data.data.id,
            name: data.data.name,
            phoneNumber: data.data.phoneNumber,
          ),
        );
      } else {
        return OtpResponse(
          status: false,
          message: data.message,
          data: OtpData(id: '', name: '', phoneNumber: ''),
        );
      }
    } catch (e) {
      print('Error: $e');
      return OtpResponse(
        status: false,
        message: 'Terjadi kesalahan, periksa koneksi Anda.',
        data: OtpData(id: '', name: '', phoneNumber: ''),
      );
    }
  }

  Future<OtpResponse> resendOtp(String phone_number) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resendOTP'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone_number}),
    );

    if (response.statusCode == 200) {
      return OtpResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to Send OTP');
    }
  }

  Future<OtpResponse> getPhonebyEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getPhoneByEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = OtpResponse.fromJson(jsonDecode(response.body));
      return (data);
    } catch (e) {
      return OtpResponse(
        status: false,
        message: 'Error',
        data: OtpData(id: '', name: '', phoneNumber: ''),
      );
    }
  }

  Future<resendOTPResponse> resendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resendOTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );
      return resendOTPResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return resendOTPResponse(
        status: false,
        message: 'Error: $e',
      );
    }
  }

  Future<OtpResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgotPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return OtpResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return OtpResponse(
        status: false,
        message: 'Error: $e',
        data: OtpData(id: '', name: '', phoneNumber: ''),
      );
    }
  }

  Future<OtpResponse> resetPassword(
      String email, String password, String confirmPassword, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'otp': otp,
        }),
      );
      return OtpResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return OtpResponse(
        status: false,
        message: 'Error: $e',
        data: OtpData(id: '', name: '', phoneNumber: ''),
      );
    }
  }
}
