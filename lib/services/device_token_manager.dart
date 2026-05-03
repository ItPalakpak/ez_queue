// lib/services/device_token_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceTokenManager {
  static const String _tokenKey = 'device_token';

  static Future<String> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    if (token == null) {
      token = const Uuid().v4();
      await prefs.setString(_tokenKey, token);
    }

    return token;
  }
}
