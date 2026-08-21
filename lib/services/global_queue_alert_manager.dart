import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ez_queue/services/device_token_manager.dart';
import 'package:ez_queue/utils/api_config.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_dialog.dart';

class GlobalQueueAlertManager {
  static final GlobalQueueAlertManager _instance = GlobalQueueAlertManager._internal();
  factory GlobalQueueAlertManager() => _instance;
  GlobalQueueAlertManager._internal();

  WebSocketChannel? _channel;
  bool _alertShown = false;
  String? _deviceToken;
  GlobalKey<NavigatorState>? navigatorKey;
  bool _isDisposed = false;

  void initialize(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
    _isDisposed = false;
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    if (_isDisposed) return;
    _deviceToken = await DeviceTokenManager.getDeviceToken();
    if (_deviceToken == null) return;

    try {
      _channel?.sink.close();
      final host = ApiConfig.reverbHost;
      final isSecure = ApiConfig.baseUrl.startsWith('https') || host.contains('trycloudflare.com') || host.contains(':443');
      final scheme = isSecure ? 'wss' : 'ws';
      _channel = WebSocketChannel.connect(
        Uri.parse('$scheme://$host/app/${ApiConfig.reverbKey}?protocol=7&client=ezqueue-mobile&version=1.0.0'),
      );

      await _channel!.ready;

      // Note: Do NOT send pusher:subscribe here. We must wait for pusher:connection_established
      // before attempting to subscribe, as per Pusher Server protocol.

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            
            // Wait for Server to authorize the socket session before subscribing
            if (data['event'] == 'pusher:connection_established') {
              _channel?.sink.add(
                jsonEncode({
                  'event': 'pusher:subscribe',
                  'data': {'channel': 'ticket.$_deviceToken'},
                }),
              );
              return;
            }

            // Reverb / Pusher requires a pong response to heavily monitor active connections.
            // Failing to respond to ping will instantly drop the socket after ~60-120 seconds.
            if (data['event'] == 'pusher:ping') {
              _channel?.sink.add(jsonEncode({'event': 'pusher:pong'}));
              return;
            }

            if (data['event'] == 'advance.alert' && !_alertShown) {
              var payloadRaw = data['data'];
              Map<String, dynamic>? payload;
              
              // Laravel broadcasts payload as a JSON-encoded string within the data object
              if (payloadRaw is String) {
                payload = jsonDecode(payloadRaw) as Map<String, dynamic>;
              } else if (payloadRaw is Map) {
                payload = payloadRaw as Map<String, dynamic>;
              }
              
              final ticketId = payload?['ticket_id'] as int?;
              final ticketNumber = payload?['ticket_number'] as String?;
              final clientName = payload?['client_name'] as String?;
              
              if (ticketId != null) {
                _showAlertModal(ticketId, ticketNumber, clientName);
              }
            }
          } catch (e) {
            // Intentionally ignore parse/cast errors
          }
        },
        onError: (error) {
          _scheduleReconnect();
        },
        onDone: () {
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 4), () {
      _connectWebSocket();
    });
  }

  /// Public entry point for external callers (e.g. FCM listeners) to trigger
  /// the advance alert dialog. Delegates to the private [_showAlertModal].
  void handleAdvanceAlert(int ticketId, String? ticketNumber, String? clientName) {
    if (_alertShown) return;
    _showAlertModal(ticketId, ticketNumber, clientName);
  }

  void _showAlertModal(int realTicketId, String? ticketNumber, String? clientName) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    _alertShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EZDialog(
        title: const Text('It\'s almost your turn!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please head to the waiting area now.'),
            const SizedBox(height: EZSpacing.md),
            if (ticketNumber != null)
              Text('Ticket: $ticketNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (clientName != null)
              Text('Client: $clientName', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          EZButton(
            isSecondary: true,
            onPressed: () {
              if (_deviceToken != null) {
                ApiService.confirmOnWay(
                  ticketId: realTicketId,
                  status: 'needs_time',
                  deviceToken: _deviceToken!,
                );
              }
              _alertShown = false;
              Navigator.pop(ctx);
            },
            child: const Text('I need more time'),
          ),
          EZButton(
            onPressed: () {
              if (_deviceToken != null) {
                ApiService.confirmOnWay(
                  ticketId: realTicketId,
                  status: 'on_way',
                  deviceToken: _deviceToken!,
                );
              }
              _alertShown = false;
              Navigator.pop(ctx);
            },
            child: const Text('I\'m on my way!'),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _isDisposed = true;
    _channel?.sink.close();
  }
}
