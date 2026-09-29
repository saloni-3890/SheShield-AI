import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'emergency_contact_service.dart';
import 'sms_service.dart';

class SosService {
  final AuthService _authService = AuthService();
  final EmergencyContactService _contactService =
      EmergencyContactService();
  final SmsService _smsService = SmsService();

  Future<bool> activateSOS() async {
    // 1. Check location service
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please turn on Location');
    }

    // 2. Check permission
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    // 3. Get current location
    final Position position =
        await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // 4. Save SOS in backend
    final success = await _authService.createSosAlert(
      position.latitude,
      position.longitude,
    );

    if (!success) {
      throw Exception(
        'SOS location could not be sent to server',
      );
    }

    // 5. Get emergency contacts
    final contacts = await _contactService.getContacts();

    if (contacts.isEmpty) {
      throw Exception(
        'SOS saved, but no emergency contacts found.',
      );
    }

    // 6. SMS permission
    final smsPermission =
        await _smsService.requestPermission();

    if (!smsPermission) {
      throw Exception('SMS permission denied.');
    }

    // 7. Send SMS
    for (final contact in contacts) {
      final phone =
          contact["phone"]?.toString().trim();

      if (phone == null || phone.isEmpty) {
        continue;
      }

      await _smsService.sendSosSms(
        phone: phone,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    return true;
  }
}