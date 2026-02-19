/// Model class for queue form data.
/// Contains all information collected during the queue registration process.
class QueueFormData {
  final String? department;
  final List<String> services;
  final String? userType;
  final String? idNumber;
  final bool isPWD;
  final String? pwdSpecification;
  final String? fullName;
  final String? email;

  const QueueFormData({
    this.department,
    this.services = const [],
    this.userType,
    this.idNumber,
    this.isPWD = false,
    this.pwdSpecification,
    this.fullName,
    this.email,
  });

  /// Create a copy with updated fields.
  QueueFormData copyWith({
    String? department,
    List<String>? services,
    String? userType,
    String? idNumber,
    bool? isPWD,
    String? pwdSpecification,
    String? fullName,
    String? email,
  }) {
    return QueueFormData(
      department: department ?? this.department,
      services: services ?? this.services,
      userType: userType ?? this.userType,
      idNumber: idNumber ?? this.idNumber,
      isPWD: isPWD ?? this.isPWD,
      pwdSpecification: pwdSpecification ?? this.pwdSpecification,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }

  /// Check if all required fields are filled.
  bool get isComplete {
    return department != null &&
        services.isNotEmpty &&
        userType != null &&
        fullName != null &&
        email != null &&
        (!isPWD || (pwdSpecification != null && pwdSpecification!.isNotEmpty)) &&
        (!['Student', 'Faculty', 'Staff', 'Alumni'].contains(userType) ||
            (idNumber != null && idNumber!.isNotEmpty));
  }
}

