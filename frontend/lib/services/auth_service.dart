import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
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

  Future<bool> createSosAlert(double latitude, double longitude) async {
    try {
      debugPrint("SOS API: Request started");
      debugPrint("SOS API: Latitude = $latitude");
      debugPrint("SOS API: Longitude = $longitude");

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        debugPrint("SOS API: JWT token NOT FOUND");
        return false;
      }

      debugPrint("SOS API: JWT token found");
      debugPrint("SOS API: Sending request to ${ApiConfig.baseUrl}/sos");

      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/sos"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({"latitude": latitude, "longitude": longitude}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("SOS API: Response status = ${response.statusCode}");
      debugPrint("SOS API: Response body = ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("SOS API ERROR: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  Future<bool> saveFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      debugPrint("FCM: JWT token not found");
      return false;
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/fcm-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"fcmToken": fcmToken}),
    );

    debugPrint("FCM SAVE STATUS: ${response.statusCode}");
    debugPrint("FCM SAVE RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }
}
