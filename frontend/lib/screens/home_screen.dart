import 'package:flutter/material.dart';
import 'ai_companion_screen.dart';
import '../services/auth_service.dart';
import 'emergency_contacts_screen.dart';
import 'login_screen.dart';
import 'stories_screen.dart';
import '../services/sos_service.dart';
import 'safety_toolkit_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();

  final SosService sosService = SosService();
  bool sosLoading = false;

  Future<void> activateSOS() async {
    if (sosLoading) return;

    setState(() {
      sosLoading = true;
    });

    try {
      final success = await sosService.activateSOS();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🚨 SOS Activated!\n"
              "Location saved and emergency contacts notified.",
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint("SOS ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("SOS failed: $e"),
          duration: const Duration(seconds: 4),
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
            const SizedBox(height: 16),

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AiCompanionScreen(),
      ),
    );
  },
  icon: const Icon(Icons.psychology),
  label: const Text("Ask SheShield AI"),
),
const SizedBox(height: 16),

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StoriesScreen(),
      ),
    );
  },
  icon: const Icon(Icons.auto_stories),
  label: const Text("Real Stories"),
),
const SizedBox(height: 16),

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafetyToolkitScreen(),
      ),
    );
  },
  icon: const Icon(Icons.shield_outlined),
  label: const Text("Safety Toolkit"),
),
          ],
        ),
      ),
    );
  }
}
