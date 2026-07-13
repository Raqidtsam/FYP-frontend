import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Send token to backend
    if (token != null) {
      await _registerToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken);
    });

    // Setup local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(settings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to specific screen
    });
  }

  static Future<void> _registerToken(String token) async {
    final authToken = await AuthService().getToken();
    if (authToken == null) return;

    await http.post(
      Uri.parse('http://localhost:8000/api/auth/register-fcm-token/'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'token': token, 'device': 'android'}),
    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default',
      'Smart Geo Investment',
      channelDescription: 'Investment alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Smart Geo Investment',
      message.notification?.body ?? '',
      details,
    );
  }
}