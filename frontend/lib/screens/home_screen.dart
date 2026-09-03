import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import 'emergency_contacts_screen.dart';
import 'login_screen.dart';
import '../services/emergency_contact_service.dart';
import '../services/sms_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  final EmergencyContactService contactService = EmergencyContactService();
  final SmsService smsService = SmsService();

  bool sosLoading = false;

  Future<void> activateSOS() async {
    if (sosLoading) return;

    setState(() {
      sosLoading = true;
    });

    try {
      // 1. Check whether location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please turn on Location")),
        );

        return;
      }

      // 2. Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );

        return;
      }

      // 3. Get current location
      debugPrint("SOS: Location request started");

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint("SOS: Location received");
      debugPrint("SOS Latitude: ${position.latitude}");
      debugPrint("SOS Longitude: ${position.longitude}");

      // 4. Save SOS in backend
      final success = await authService.createSosAlert(
        position.latitude,
        position.longitude,
      );

      if (!success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SOS location could not be sent to server"),
          ),
        );

        return;
      }

      // 5. Get emergency contacts
      debugPrint("SOS: Loading emergency contacts...");

      final contacts = await contactService.getContacts();

      debugPrint("SOS: ${contacts.length} emergency contacts found");

      if (contacts.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SOS saved, but no emergency contacts found."),
          ),
        );

        return;
      }

      // 6. Request SMS permission
      final smsPermission = await smsService.requestPermission();

      if (!smsPermission) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("SMS permission denied.")));

        return;
      }

      // 7. Send SMS to every emergency contact
      int sentCount = 0;

      for (final contact in contacts) {
        final phone = contact["phone"]?.toString().trim();

        if (phone == null || phone.isEmpty) {
          debugPrint("SOS: No phone number for ${contact["name"]}");
          continue;
        }

        debugPrint("SOS: Sending SMS to ${contact["name"]} - $phone");

        final smsSent = await smsService.sendSosSms(
          phone: phone,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (smsSent) {
          sentCount++;

          debugPrint("SOS: SMS successfully sent to $phone");
        }
      }

      // 8. Show result
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🚨 SOS Activated!\n"
            "Location saved successfully.\n"
            "SMS sent to $sentCount/${contacts.length} contacts.",
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint("SOS ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("SOS failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          sosLoading = false;
        });
      }
    }
  }

  void showSOSDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Emergency SOS"),
          content: const Text("Are you sure you want to activate SOS?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                activateSOS();
              },
              child: const Text("ACTIVATE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SheShield AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);

              await authService.logout();

              if (!mounted) return;

              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 100, color: Colors.pink),

            const SizedBox(height: 20),

            const Text(
              "Welcome to SheShield AI",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("You are logged in successfully."),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: sosLoading ? null : showSOSDialog,
              icon: sosLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.warning_rounded),
              label: Text(sosLoading ? "ACTIVATING..." : "SOS"),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.contact_phone),
              label: const Text("Emergency Contacts"),
            ),
          ],
        ),
      ),
    );
  }
}
