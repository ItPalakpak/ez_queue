// src/services/api_service.dart
// CHANGED: new API service to handle kiosk backend requests
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/api_models.dart';
import '../models/queue_ticket.dart';

class ApiService {
  final http.Client _client = http.Client();

  // CHANGED: added getDepartments method for dynamic fetching
  Future<List<ApiDepartment>> getDepartments() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.departments}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data
            .map((json) => ApiDepartment.fromJson(json))
            .where((dept) => dept.status == 'active')
            .toList();
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: fixed parsing — API returns {data: {services: [...], allow_multiple_services: bool}}
  Future<ApiServicesResponse> getServices(int departmentId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.services(departmentId)}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          body['data'] ?? {},
        );
        return ApiServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: added getCourses method
  Future<List<ApiCourse>> getCourses() async {
    try {
      // CHANGED: cache-buster ensures fresh data on every poll (5 s interval)
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.courses}').replace(
        queryParameters: {
          '_t': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data
            .map((json) => ApiCourse.fromJson(json))
            .where((course) => course.status == 'active')
            .toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: added getSettings method
  Future<ApiSettings> getSettings() async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.settings}'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return ApiSettings.fromJson(body['data'] ?? {});
    }
    // CHANGED: rethrow so Riverpod enters error state instead of silently defaulting to true
    throw Exception('Failed to load settings: ${response.statusCode}');
  }

  static Future<bool> confirmOnWay({
    required int ticketId,
    required String status,
    required String deviceToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/kiosk/tickets/$ticketId/on-way',
    );

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status, 'device_token': deviceToken}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // CHANGED: added createTicket
  Future<QueueTicket> createTicket(Map<String, dynamic> payload) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/kiosk/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (payload.containsKey('device_token') &&
              payload['device_token'] != null)
            'X-Device-Token': payload['device_token'],
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return QueueTicket.fromJson(body['data']);
      } else {
        // CHANGED: Parse error response and extract user-friendly message
        String errorMessage;
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage =
              errorBody['message'] ??
              'Failed to create ticket. Please try again.';
        } catch (_) {
          errorMessage = 'Failed to create ticket. Please try again.';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // CHANGED: Re-throw to preserve the user-friendly error message from backend
      rethrow;
    }
  }

  // CHANGED: added checkActiveTickets method
  Future<Map<String, dynamic>> checkActiveTickets(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/kiosk/check-active-tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return body['data'] ?? {};
      } else {
        throw Exception('Failed to check active tickets');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: added display endpoint fetching
  Future<ApiDisplayData> getDepartmentLiveQueue(int departmentId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/display/$departmentId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return ApiDisplayData.fromJson(body['data']);
      } else {
        throw Exception('Failed to load queue data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: added findTicketByNumber for landing page lookup
  Future<Map<String, dynamic>> findTicketByNumber(
    String ticketNumber, {
    String? deviceToken,
  }) async {
    try {
      var uri = Uri.parse(
        '${ApiConfig.baseUrl}/kiosk/tickets/number/$ticketNumber',
      );
      if (deviceToken != null && deviceToken.isNotEmpty) {
        uri = uri.replace(queryParameters: {'device_token': deviceToken});
      }
      final response = await _client.get(uri);
      final Map<String, dynamic> body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body['data'];
      } else {
        throw Exception(body['message'] ?? 'Ticket not found.');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // CHANGED: added cancelTicket for client-side queue cancellation with reason
  Future<bool> cancelTicket(int ticketId, String reason) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cancelTicket(ticketId)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Failed to cancel ticket.');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Global instance for providers
final apiService = ApiService();
