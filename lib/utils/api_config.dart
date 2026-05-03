import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/server_config.dart';

class ApiConfig {
  static ServerConfig? _cachedServerConfig;
  static String? _resolvedBaseUrl;
  static String? _resolvedReverbHost;

  // CHANGED: resolve URLs from Firestore at startup and cache them
  static Future<void> init() async {
    final config = await _fetchServerConfig();

    debugPrint(
      '[ApiConfig] Firestore config: ip=${config?.ip}, lanIp=${config?.lanIp}, tunnelsActive=${config?.tunnelsActive}, backendTunnel=${config?.backendTunnel}',
    );

    if (config != null &&
        config.tunnelsActive &&
        config.backendTunnel != null) {
      final reachable = await _isReachable(config.backendTunnel!);
      debugPrint('[ApiConfig] Tunnel reachable: $reachable');
      if (reachable) {
        _resolvedBaseUrl = '${config.backendTunnel!}/api/v1';
      }
    }

    // CHANGED: Try LAN IP first (same-network clients), then public IP
    if (_resolvedBaseUrl == null && config != null) {
      if (config.lanIp != null && config.lanIp!.isNotEmpty) {
        final lanReachable = await _isReachable('http://${config.lanIp}:8000');
        debugPrint(
          '[ApiConfig] LAN IP ${config.lanIp} reachable: $lanReachable',
        );
        if (lanReachable) {
          _resolvedBaseUrl = 'http://${config.lanIp}:8000/api/v1';
        }
      }
      if (_resolvedBaseUrl == null && config.ip.isNotEmpty) {
        debugPrint('[ApiConfig] Falling back to public IP: ${config.ip}');
        _resolvedBaseUrl = 'http://${config.ip}:8000/api/v1';
      }
    }

    if (config != null && config.tunnelsActive && config.reverbTunnel != null) {
      final tunnel = config.reverbTunnel!;
      if (tunnel.startsWith('wss://')) {
        _resolvedReverbHost = tunnel
            .replaceFirst('wss://', '')
            .replaceAll(':443', '');
      } else {
        _resolvedReverbHost = tunnel;
      }
    }

    // CHANGED: Prefer LAN IP for Reverb if base URL resolved to LAN
    if (_resolvedReverbHost == null && config != null) {
      if (_resolvedBaseUrl != null &&
          _resolvedBaseUrl!.contains(config.lanIp ?? '')) {
        _resolvedReverbHost = '${config.lanIp}:8085';
      } else if (config.ip.isNotEmpty) {
        _resolvedReverbHost = '${config.ip}:8085';
      }
    }

    debugPrint('[ApiConfig] Resolved baseUrl: $_resolvedBaseUrl');
    debugPrint('[ApiConfig] Resolved reverbHost: $_resolvedReverbHost');
  }

  // CHANGED: fetch server config from Firestore (returns null if unavailable)
  static Future<ServerConfig?> _fetchServerConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('server_config')
          .doc('current')
          .get(const GetOptions(source: Source.serverAndCache));

      if (doc.exists) {
        _cachedServerConfig = ServerConfig.fromFirestore(doc);
        debugPrint('[ApiConfig] Firestore doc data: ${doc.data()}');
        return _cachedServerConfig;
      } else {
        debugPrint('[ApiConfig] Firestore doc does NOT exist!');
      }
    } catch (e) {
      debugPrint('[ApiConfig] _fetchServerConfig ERROR: $e');
    }
    return _cachedServerConfig;
  }

  // CHANGED: probe a URL to check if tunnel is actually alive
  static Future<bool> _isReachable(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/api/v1/ping'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// The base URL for the backend API.
  /// Resolution order: Firestore resolved → .env → platform default
  static String get baseUrl {
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;

    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (Platform.isAndroid) return 'http://193.169.19.162:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1'; // Windows, iOS simulator
  }

  // API Endpoints
  static const String departments = '/kiosk/departments';
  static String services(int departmentId) =>
      '/kiosk/departments/$departmentId/services';
  static const String courses = '/kiosk/courses';
  static const String settings = '/kiosk/settings';
  static String cancelTicket(int ticketId) => '/kiosk/tickets/$ticketId/cancel';

  // Reverb WebSocket
  static String get reverbHost {
    if (_resolvedReverbHost != null) return _resolvedReverbHost!;

    final envHost = dotenv.env['REVERB_HOST'];
    if (envHost != null && envHost.isNotEmpty) return envHost;

    if (kIsWeb) return '127.0.0.1:8085';
    if (Platform.isAndroid) return '192.168.18.161:8085';
    return '127.0.0.1:8085';
  }

  static const String reverbKey = 'ez_queue_key';
}
