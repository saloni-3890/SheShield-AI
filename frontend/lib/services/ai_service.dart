import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AiService {
  static const String baseUrl = "http://10.243.54.100:5000/api";

  static Future<Map<String, dynamic>> analyzeProblem(
    String problem,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/analyze'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'problem': problem,
      }),
    );

   debugPrint("AI STATUS: ${response.statusCode}");
debugPrint("AI RESPONSE: ${response.body}");

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return data['data'];
} else {
  throw Exception(
    'AI request failed: ${response.statusCode} ${response.body}',
  );
}
  }
}