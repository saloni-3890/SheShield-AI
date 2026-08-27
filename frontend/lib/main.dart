import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SheShieldApp());
}

class SheShieldApp extends StatelessWidget {
  const SheShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SheShield AI',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}