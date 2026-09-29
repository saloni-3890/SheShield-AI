import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SafeJourneyService {
  static const String baseUrl = "http://10.112.81.100:5000/api";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Start a new safe journey
  static Future<Map<String, dynamic>> startJourney({
    required String destination,
    required DateTime expectedArrival,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/safe-journey/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'destination': destination,
        'expectedArrival': expectedArrival.toIso8601String(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to start journey',
    );
  }

  // Get active journey
  static Future<Map<String, dynamic>?> getActiveJourney() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/safe-journey/active'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    }

    throw Exception(
      data['message'] ?? 'Failed to get active journey',
    );
  }

  // Check-in
  static Future<Map<String, dynamic>> checkIn() async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/safe-journey/check-in'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Check-in failed',
    );
  }

  // Complete journey
  static Future<Map<String, dynamic>> completeJourney() async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/safe-journey/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to complete journey',
    );
  }

  // Cancel journey
  static Future<Map<String, dynamic>> cancelJourney() async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/safe-journey/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to cancel journey',
    );
  }
}