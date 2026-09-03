import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class EmergencyContactService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<List<dynamic>> getContacts() async {
    final token = await _getToken();

    if (token == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts"),
      headers: {"Authorization": "Bearer $token"},
    );

    debugPrint("GET CONTACTS STATUS: ${response.statusCode}");
    debugPrint("GET CONTACTS RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["contacts"] ?? [];
    }

    return [];
  }

  Future<bool> addContact(String name, String phone, String relation) async {
    debugPrint("ADD CONTACT: METHOD CALLED");
    final token = await _getToken();

    if (token == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "phone": phone, "relation": relation}),
    );

    debugPrint("ADD CONTACT STATUS: ${response.statusCode}");
    debugPrint("ADD CONTACT RESPONSE: ${response.body}");

    return response.statusCode == 201;
  }

  Future<bool> updateContact(
    int id,
    String name,
    String phone,
    String relation,
  ) async {
    final token = await _getToken();

    if (token == null) {
      return false;
    }

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "phone": phone, "relation": relation}),
    );

    debugPrint("UPDATE CONTACT STATUS: ${response.statusCode}");
    debugPrint("UPDATE CONTACT RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  Future<bool> saveContactFcmToken(int id, String fcmToken) async {
    final token = await _getToken();

    if (token == null) {
      return false;
    }

    final response = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts/$id/fcm-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"fcmToken": fcmToken}),
    );

    debugPrint("SAVE CONTACT FCM STATUS: ${response.statusCode}");
    debugPrint("SAVE CONTACT FCM RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  Future<bool> linkContactUser(int contactId, int contactUserId) async {
    final token = await _getToken();

    if (token == null) {
      return false;
    }

    final response = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts/$contactId/link-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"contactUserId": contactUserId}),
    );

    debugPrint("LINK CONTACT STATUS: ${response.statusCode}");

    debugPrint("LINK CONTACT RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  Future<bool> deleteContact(int id) async {
    final token = await _getToken();

    if (token == null) {
      return false;
    }

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/emergency-contacts/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    debugPrint("DELETE CONTACT STATUS: ${response.statusCode}");
    debugPrint("DELETE CONTACT RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }
}
