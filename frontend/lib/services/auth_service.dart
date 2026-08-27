import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}