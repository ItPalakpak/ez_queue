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
  void updateDepartment({required String department}) {
    state = state.copyWith(
      department: department,
      // Clear services when department changes
      services: [],
      purpose: null,
      items: [],
    );
  }

  /// Update department and services (legacy compatibility).
  void updateDepartmentAndServices({
    required String department,
    required List<String> services,
  }) {
    state = state.copyWith(department: department, services: services);
  }

  /// Update service details: services, purpose, and items.
  void updateServiceDetails({
    required List<String> services,
    String? purpose,
    List<ServiceItem>? items,
  }) {
    state = state.copyWith(
      services: services,
      purpose: purpose,
      items: items ?? state.items,
    );
  }

  /// Update user type, ID number, course/program, and PWD info.
  void updateUserType({
    required String userType,
    String? idNumber,
    String? courseProgram,
    bool? isPWD,
    String? pwdSpecification,
  }) {
    state = state.copyWith(
      userType: userType,
      idNumber: idNumber,
      courseProgram: courseProgram,
      isPWD: isPWD ?? state.isPWD,
      pwdSpecification: pwdSpecification ?? state.pwdSpecification,
    );
  }

  /// Update PWD information.
  void updatePWD({required bool isPWD, String? pwdSpecification}) {
    state = state.copyWith(isPWD: isPWD, pwdSpecification: pwdSpecification);
  }

  /// Update personal information.
  void updatePersonalInfo({
    required String fullName,
    required String email,
    String? contactNumber,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      contactNumber: contactNumber,
    );
  }

  /// Reset form data.
  void reset() {
    state = const QueueFormData();
  }
}
