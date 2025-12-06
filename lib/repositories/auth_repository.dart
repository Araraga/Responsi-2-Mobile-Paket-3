import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl = "http://192.168.100.39:3000";

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? "Login Gagal");
    }
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'username': username, 'password': password},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? "Registrasi Gagal");
    }
  }
}
