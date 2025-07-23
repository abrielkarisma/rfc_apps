import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/service/token.dart';

class RfcManagementService {
  final String baseUrl = '${dotenv.env["BASE_URL"]}';
  Future<Map<String, dynamic>> getTokoByTypeRFC() async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/store/toko/rfc'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return getTokoByTypeRFC();
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'message': 'No toko found with type RFC', 'data': []};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'status': false,
          'message': responseData['message'] ?? 'Unknown error occurred',
          'data': []
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: $e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> createTokoWithTypeRFC({
    required String nama,
    required String phone,
    required String alamat,
    String? logoToko,
    String? deskripsi,
  }) async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/store/toko/createRFC'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'phone': phone,
          'alamat': alamat,
          'logoToko': logoToko ?? '',
          'deskripsi': deskripsi ?? '',
        }),
      );

      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return createTokoWithTypeRFC(
          nama: nama,
          phone: phone,
          alamat: alamat,
          logoToko: logoToko,
          deskripsi: deskripsi,
        );
      }

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to create toko',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateTokoRFC({
    required String tokoId,
    required String nama,
    required String phone,
    required String alamat,
    String? logoToko,
    String? deskripsi,
  }) async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/store/toko/rfc/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tokoId': tokoId,
          'nama': nama,
          'phone': phone,
          'alamat': alamat,
          'logoToko': logoToko ?? '',
          'deskripsi': deskripsi ?? '',
        }),
      );

      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return updateTokoRFC(
          tokoId: tokoId,
          nama: nama,
          phone: phone,
          alamat: alamat,
          logoToko: logoToko,
          deskripsi: deskripsi,
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUsersByRolePjawab() async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/pjawab'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return getUsersByRolePjawab();
      } else if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'message': 'No users found with the specified role',
          'data': []
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'status': false,
          'message': responseData['message'] ?? 'Unknown error occurred',
          'data': []
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: $e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> updateUserPjawab({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/user/pjawab/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
        }),
      );
      print(response.body);
      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return updateUserPjawab(
          id: id,
          name: name,
          email: email,
          phone: phone,
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUserPjawab(String userId) async {
    try {
      final token = await tokenService().getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/user/pjawab/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isDeleted': true,
        }),
      );

      if (response.statusCode == 401) {
        await tokenService().refreshToken();
        return deleteUserPjawab(userId);
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }
}
