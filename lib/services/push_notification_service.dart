import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ez_queue/utils/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<String?> initializeAndGetToken() async {
    try {
      // 1. Request permission from user (iOS requires this, Android 13+ requires this)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint("Push Notification Status: \${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Fetch the FCM token to give to Laravel
        String? token = await _firebaseMessaging.getToken();
        debugPrint("FCM Token Generated: \$token");
        return token;
      } else {
        debugPrint("User declined or has not accepted push notifications.");
      }
    } catch (e) {
      debugPrint("Error generating FCM token: \$e");
    }
    return null;
  }

  static void listenForTokenRefresh(String deviceToken) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
       // Send the rotated token to the backend to update the active ticket
       try {
         debugPrint("FCM Token dynamically refreshed. Syncing to backend...");
         final url = Uri.parse('${ApiConfig.baseUrl}/kiosk/tickets/update-fcm');
         final response = await http.patch(
           url,
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
           body: jsonEncode({
             'device_token': deviceToken,
             'fcm_token': newToken,
           }),
         );
         if (response.statusCode != 200) {
           debugPrint("Failed to sync new FCM token: \${response.body}");
         }
       } catch (e) {
         debugPrint("Error syncing new FCM token: \$e");
       }
    });
  }
}
