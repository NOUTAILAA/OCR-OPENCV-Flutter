import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://192.168.1.102:5001";

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    }
    return null;
  }

  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      body: jsonEncode({"email": email, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    return response.statusCode == 201;
  }



  static Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot_password"),
      body: jsonEncode({"email": email}),
      headers: {"Content-Type": "application/json"},
    );

    return response.statusCode == 200;
  }
}
