import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/models/queue_form_data.dart';

/// Provider for queue form data state management.
final queueFormProvider =
    StateNotifierProvider<QueueFormNotifier, QueueFormData>((ref) {
      return QueueFormNotifier();
    });

/// Notifier for managing queue form data state.
class QueueFormNotifier extends StateNotifier<QueueFormData> {
  QueueFormNotifier() : super(const QueueFormData());

  /// Update department selection only.
  void updateDepartment({
    required int departmentId,
    required String department,
  }) {
    state = state.copyWith(
      departmentId: departmentId,
      department: department,
      // Clear services when department changes
      serviceIds: [],
      services: [],
      purpose: null,
      items: [],
    );
  }

  /// Update department and services (legacy compatibility).
  void updateDepartmentAndServices({
    required int departmentId,
    required String department,
    required List<int> serviceIds,
    required List<String> services,
  }) {
    state = state.copyWith(
      departmentId: departmentId,
      department: department,
      serviceIds: serviceIds,
      services: services,
    );
  }

  /// Update user type information.
  void updateUserType({required String userType}) {
    state = state.copyWith(userType: userType);
  }

  /// Update identity information.
  void updateIdentityInfo({
    required String fullName,
    String? idNumber,
    int? courseId,
    String? courseProgram,
  }) {
    state = state.copyWith(
      fullName: fullName,
      idNumber: idNumber,
      courseId: courseId,
      courseProgram: courseProgram,
    );
  }

  /// Update contact information and priority.
  void updateContactInfo({
    required String email,
    String? contactNumber,
    required int priorityWeight,
    required bool isPWD,
    String? pwdSpecification,
    String? priorityIdNumber,
    List<int> disabledDepartments = const [],
  }) {
    state = state.copyWith(
      email: email,
      contactNumber: contactNumber,
      priorityWeight: priorityWeight,
      isPWD: isPWD,
      pwdSpecification: pwdSpecification,
      priorityIdNumber: priorityIdNumber,
      disabledDepartments: disabledDepartments,
    );
  }

  /// Update service selection only.
  void updateServiceInfo({
    required List<int> serviceIds,
    required List<String> services,
  }) {
    state = state.copyWith(serviceIds: serviceIds, services: services);
  }

  /// Update details information.
  void updateDetailsInfo({String? purpose, List<ServiceItem>? items}) {
    state = state.copyWith(purpose: purpose, items: items ?? state.items);
  }

  /// Reset form data.
  void reset() {
    state = const QueueFormData();
  }
}
