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

  /// Update department and services.
  void updateDepartmentAndServices({
    required String department,
    required List<String> services,
  }) {
    state = state.copyWith(
      department: department,
      services: services,
    );
  }

  /// Update user type and ID number.
  void updateUserType({
    required String userType,
    String? idNumber,
    bool? isPWD,
    String? pwdSpecification,
  }) {
    state = state.copyWith(
      userType: userType,
      idNumber: idNumber,
      isPWD: isPWD ?? state.isPWD,
      pwdSpecification: pwdSpecification ?? state.pwdSpecification,
    );
  }

  /// Update PWD information.
  void updatePWD({
    required bool isPWD,
    String? pwdSpecification,
  }) {
    state = state.copyWith(
      isPWD: isPWD,
      pwdSpecification: pwdSpecification,
    );
  }

  /// Update personal information.
  void updatePersonalInfo({
    required String fullName,
    required String email,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
    );
  }

  /// Reset form data.
  void reset() {
    state = const QueueFormData();
  }
}

