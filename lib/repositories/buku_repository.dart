import 'dart:convert';
import 'package:http/http.dart' as http;

class BukuRepository {
  final String baseUrl = "http://192.168.100.39:3000";

  Future<List<dynamic>> getBuku() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal memuat data");
    }
  }

  Future<void> saveBuku(Map<String, String> data, bool isEdit) async {
    final endpoint = isEdit ? '/update' : '/create';
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      body: data,
    );
    if (response.statusCode != 200) throw Exception("Gagal menyimpan data");
  }

  Future<void> deleteBuku(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete'),
      body: {'id': id},
    );
    if (response.statusCode != 200) throw Exception("Gagal menghapus data");
  }
}
