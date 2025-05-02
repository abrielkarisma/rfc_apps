import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryService {
  final String apiKey = 'nez8ufrf3XkRrtfrEryjwYMKOi8';
  final String apiSecret = '914877962318655';
  final apiUrl = 'https://api.cloudinary.com/v1_1/do4mvm3ta/image/upload';

  Future<Map<String, dynamic>> getUploadUrl(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['api_key'] = apiKey
      ..fields['upload_preset'] = 'default'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return {
        'url': data['secure_url'],
      };
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
