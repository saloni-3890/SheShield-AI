import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import 'emergency_contacts_screen.dart';
import 'login_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();

  bool sosLoading = false;

  Future<void> activateSOS() async {
    if (sosLoading) return;

    setState(() {
      sosLoading = true;
    });

    try {
      // Check whether location service is enabled
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please turn on Location"),
          ),
        );

        return;
      }

      // Check location permission
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission denied"),
          ),
        );

        return;
      }

      debugPrint("SOS: Location request started");

      // Get current location
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint("SOS: Location received");
      debugPrint("SOS Latitude: ${position.latitude}");
      debugPrint("SOS Longitude: ${position.longitude}");

      // Send location to backend
      final success = await authService.createSosAlert(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "SOS Activated!\n"
              "Location sent successfully.\n"
              "Lat: ${position.latitude}\n"
              "Long: ${position.longitude}",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "SOS location could not be sent to server",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("SOS ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "SOS failed: $e",
          ),
        ),
      );
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
          content: const Text(
            "Are you sure you want to activate SOS?",
          ),
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
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
  );
},
    ),
  ],
),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield,
              size: 100,
              color: Colors.pink,
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome to SheShield AI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "You are logged in successfully.",
            ),

            const SizedBox(height: 40),
       
            ElevatedButton.icon(
              onPressed: sosLoading ? null : showSOSDialog,
              icon: sosLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.warning_rounded),
              label: Text(
                sosLoading ? "ACTIVATING..." : "SOS",
              ),
            ),
             const SizedBox(height: 16),

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const EmergencyContactsScreen(),
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