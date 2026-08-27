import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SheShield AI"),
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
              onPressed: () {},
              icon: const Icon(Icons.warning_rounded),
              label: const Text("SOS"),
            ),
          ],
        ),
      ),
    );
  }
}