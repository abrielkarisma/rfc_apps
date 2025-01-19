import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/model/artikel.dart';

Future<List<Artikel>> fetchArtikel() async {
  final response = await http
      .get(Uri.parse('https://678c99d7f067bf9e24e7b4da.mockapi.io/Article'));

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    List<Artikel> artikels =
        body.map((dynamic artikel) => Artikel.fromJson(artikel)).toList();
    return artikels;
  } else {
    throw Exception('Failed to load artikel');
  }
}
