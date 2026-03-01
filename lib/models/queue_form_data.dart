/// Represents a single item with name and quantity for service requests.
class ServiceItem {
  final String name;
  final int quantity;

  const ServiceItem({required this.name, required this.quantity});
}

/// Model class for queue form data.
/// Contains all information collected during the queue registration process.
class QueueFormData {
  final String? department;
  final List<String> services;
  final String? purpose;
  final List<ServiceItem> items;
  final String? userType;
  final String? idNumber;
  final String? courseProgram;
  final bool isPWD;
  final String? pwdSpecification;
  final String? fullName;
  final String? email;
  final String? contactNumber;

  const QueueFormData({
    this.department,
    this.services = const [],
    this.purpose,
    this.items = const [],
    this.userType,
    this.idNumber,
    this.courseProgram,
    this.isPWD = false,
    this.pwdSpecification,
    this.fullName,
    this.email,
    this.contactNumber,
  });

  /// Create a copy with updated fields.
  QueueFormData copyWith({
    String? department,
    List<String>? services,
    String? purpose,
    List<ServiceItem>? items,
    String? userType,
    String? idNumber,
    String? courseProgram,
    bool? isPWD,
    String? pwdSpecification,
    String? fullName,
    String? email,
    String? contactNumber,
  }) {
    return QueueFormData(
      department: department ?? this.department,
      services: services ?? this.services,
      purpose: purpose ?? this.purpose,
      items: items ?? this.items,
      userType: userType ?? this.userType,
      idNumber: idNumber ?? this.idNumber,
      courseProgram: courseProgram ?? this.courseProgram,
      isPWD: isPWD ?? this.isPWD,
      pwdSpecification: pwdSpecification ?? this.pwdSpecification,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }

  /// Check if all required fields are filled.
  bool get isComplete {
    return department != null &&
        services.isNotEmpty &&
        userType != null &&
        fullName != null &&
        email != null &&
        contactNumber != null &&
        (!isPWD ||
            (pwdSpecification != null && pwdSpecification!.isNotEmpty)) &&
        (!['Student', 'Faculty', 'Staff', 'Alumni'].contains(userType) ||
            (idNumber != null && idNumber!.isNotEmpty));
  }
}
