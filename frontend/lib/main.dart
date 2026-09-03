import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel sosChannel = AndroidNotificationChannel(
  'sos_alerts',
  'SOS Alerts',
  description: 'Emergency SOS notifications',
  importance: Importance.max,
  playSound: true,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint("FCM Background Message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Local notification initialization
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  // Create SOS notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(sosChannel);

  // FCM permission
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint("FCM Permission: ${settings.authorizationStatus}");

  // FCM token
  final token = await messaging.getToken();

  debugPrint("🔥 FCM TOKEN: $token");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  debugPrint("🚀 ABOUT TO RUN APP");

  runApp(const SheShieldApp());

  debugPrint("🚀 RUN APP CALLED");

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint("🔥 FCM FOREGROUND MESSAGE: ${message.messageId}");

    final notification = message.notification;

    if (notification != null) {
      await flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title ?? "SOS ALERT",
        body: notification.body ?? "Emergency alert received",
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sos_alerts',
            'SOS Alerts',
            channelDescription: 'Emergency SOS notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }
  });

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const HomeScreen(),
    );
  }
}
