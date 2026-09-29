import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StoryService {
  static const String baseUrl = "http://10.112.81.100:5000/api";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<dynamic>> getStories() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/stories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception('Failed to load stories');
  }

  static Future<Map<String, dynamic>> createStory({
    required String title,
    required String content,
    required String category,
    bool isAnonymous = true,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/stories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'category': category,
        'isAnonymous': isAnonymous,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to submit story');
  }

  static Future<List<dynamic>> getMyStories() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/stories/my'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }

    throw Exception('Failed to load your stories');
  }

  static Future<void> deleteStory(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/stories/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete story');
    }
  }
}