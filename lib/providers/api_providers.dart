import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

// CHANGED: Provided Riverpod FutureProviders to expose backend API data

final apiDepartmentsProvider = FutureProvider<List<ApiDepartment>>((ref) async {
  return await apiService.getDepartments();
});

// CHANGED: StreamProvider polls every 5 s so service changes are reflected
// in real-time — matches the React frontend polling pattern.
// autoDispose stops polling when no page is watching.
final apiServicesProvider = StreamProvider.autoDispose
    .family<ApiServicesResponse, int>((ref, departmentId) async* {
      while (true) {
        try {
          yield await apiService.getServices(departmentId);
        } catch (_) {
          // Skip failed fetch; keep last emitted value and retry next interval
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    });

// CHANGED: StreamProvider polls every 5 s so deactivated courses/colleges
// are reflected in real-time on the identity page — no restart required.
// autoDispose stops polling when no page is watching.
final apiCoursesProvider = StreamProvider.autoDispose<List<ApiCourse>>((
  ref,
) async* {
  while (true) {
    try {
      yield await apiService.getCourses();
    } catch (_) {
      // Skip failed fetch; keep last emitted value and retry next interval
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

// CHANGED: StreamProvider polls every 10 s so the Get A Ticket button
// appears/disappears in real-time when an admin toggles remote queuing —
// no app restart required. autoDispose stops polling when no page is watching.
final apiSettingsProvider = StreamProvider.autoDispose<ApiSettings>((
  ref,
) async* {
  while (true) {
    try {
      yield await apiService.getSettings();
    } catch (_) {
      // Skip failed fetch; keep last emitted value and retry next interval
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});

// CHANGED: StreamProvider polls the public display endpoint every 10 s for queue data
final apiDisplayQueueProvider = StreamProvider.family
    .autoDispose<ApiDisplayData, int>((ref, departmentId) async* {
      while (true) {
        try {
          yield await apiService.getDepartmentLiveQueue(departmentId);
        } catch (_) {
          // Skip failed fetch; keep last emitted data and retry next interval
        }
        await Future.delayed(
          const Duration(seconds: 10),
        ); // Easily found 10s polling interval
      }
    });
