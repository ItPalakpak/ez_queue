/// Represents a single item with name and quantity for service requests.
class ServiceItem {
  final String name;
  final int quantity;

  const ServiceItem({required this.name, required this.quantity});
}

/// Model class for queue form data.
/// Contains all information collected during the queue registration process.
class QueueFormData {
  final int? departmentId;
  final String? department;
  final List<int> serviceIds;
  final List<String> services;
  final String? purpose;
  final List<ServiceItem> items;
  final String? userType;
  final String? idNumber;
  final int? courseId;
  final String? courseProgram;
  final bool isPWD;
  final String? pwdSpecification;
  final String? priorityIdNumber;
  final String? fullName;
  final String? email;
  final String? contactNumber;
  final int priorityWeight;
  final List<int> disabledDepartments;

  const QueueFormData({
    this.departmentId,
    this.department,
    this.serviceIds = const [],
    this.services = const [],
    this.purpose,
    this.items = const [],
    this.userType,
    this.idNumber,
    this.courseId,
    this.courseProgram,
    this.isPWD = false,
    this.pwdSpecification,
    this.priorityIdNumber,
    this.fullName,
    this.email,
    this.contactNumber,
    this.priorityWeight = 1,
    this.disabledDepartments = const [],
  });

  /// Create a copy with updated fields.
  QueueFormData copyWith({
    int? departmentId,
    String? department,
    List<int>? serviceIds,
    List<String>? services,
    String? purpose,
    List<ServiceItem>? items,
    String? userType,
    String? idNumber,
    int? courseId,
    String? courseProgram,
    bool? isPWD,
    String? pwdSpecification,
    String? priorityIdNumber,
    String? fullName,
    String? email,
    String? contactNumber,
    int? priorityWeight,
    List<int>? disabledDepartments,
  }) {
    return QueueFormData(
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      serviceIds: serviceIds ?? this.serviceIds,
      services: services ?? this.services,
      purpose: purpose ?? this.purpose,
      items: items ?? this.items,
      userType: userType ?? this.userType,
      idNumber: idNumber ?? this.idNumber,
      courseId: courseId ?? this.courseId,
      courseProgram: courseProgram ?? this.courseProgram,
      isPWD: isPWD ?? this.isPWD,
      pwdSpecification: pwdSpecification ?? this.pwdSpecification,
      priorityIdNumber: priorityIdNumber ?? this.priorityIdNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      priorityWeight: priorityWeight ?? this.priorityWeight,
      disabledDepartments: disabledDepartments ?? this.disabledDepartments,
    );
  }

  /// Check if all required fields are filled.
  bool get isComplete {
    return departmentId != null &&
        department != null &&
        serviceIds.isNotEmpty &&
        services.isNotEmpty &&
        userType != null &&
        fullName != null &&
        email != null &&
        contactNumber != null &&
        (!['Student', 'Faculty/Staff', 'Alumni'].contains(userType) ||
            (idNumber != null && idNumber!.isNotEmpty));
  }
}
