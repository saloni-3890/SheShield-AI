import 'package:flutter/services.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sheshield/sms');

  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestSmsPermission');

      return result ?? false;
    } catch (e) {
      print("SMS permission error: $e");
      return false;
    }
  }

  Future<bool> sendSosSms({
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final message =
          "🚨 SOS ALERT!\n"
          "I need help. My current location is:\n"
          "https://maps.google.com/?q=$latitude,$longitude";

      final result = await _channel.invokeMethod<bool>('sendSms', {
        'phone': phone,
        'message': message,
      });

      return result ?? false;
    } catch (e) {
      print("SMS sending error: $e");
      return false;
    }
  }
}
