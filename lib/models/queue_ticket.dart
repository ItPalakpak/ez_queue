/// Model class for queue ticket information.
class QueueTicket {
  final int id;
  final String ticketNumber;
  final String clientName;
  final String userType;
  final String? studentId;
  final String? employeeId;
  final String? phone;
  final String? email;
  final String? course;
  final String? major;
  final String? purpose;
  final int quantity;
  final int departmentId;
  final String departmentName;
  final String departmentCode;
  final String serviceName;
  final String servicePrefix;
  final bool isPriority;
  final String status;
  final DateTime createdAt;
  final String? trackingToken;
  final Map<String, String>? nameBreakdown;
  final List<dynamic>? selections;
  // CHANGED: Support additional add-on / bundled services
  final List<dynamic>? additionalServices;

  const QueueTicket({
    required this.id,
    required this.ticketNumber,
    required this.clientName,
    required this.userType,
    this.studentId,
    this.employeeId,
    this.phone,
    this.email,
    this.course,
    this.major,
    this.purpose,
    required this.quantity,
    required this.departmentId,
    required this.departmentName,
    required this.departmentCode,
    required this.serviceName,
    required this.servicePrefix,
    required this.isPriority,
    required this.status,
    required this.createdAt,
    this.trackingToken,
    this.nameBreakdown,
    this.selections,
    this.additionalServices,
  });

  // CHANGED: Defensive parsing for all fields across create, track, and active ticket endpoints
  factory QueueTicket.fromJson(Map<String, dynamic> json) {
    Map<String, String>? parsedNameBreakdown;
    if (json['name_breakdown'] != null) {
      try {
        parsedNameBreakdown = Map<String, String>.from(json['name_breakdown'] as Map);
      } catch (_) {}
    }

    DateTime parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at'].toString()).toLocal();
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return QueueTicket(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      ticketNumber: json['ticket_number']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? 'Unknown',
      userType: json['user_type']?.toString() ?? 'student',
      studentId: json['student_id']?.toString(),
      employeeId: json['employee_id']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      course: json['course']?.toString(),
      major: json['major']?.toString(),
      purpose: json['purpose']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1),
      departmentId: json['department_id'] is int ? json['department_id'] : (int.tryParse(json['department_id']?.toString() ?? '1') ?? 1),
      departmentName: json['department_name']?.toString() ?? '',
      departmentCode: json['department_code']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      servicePrefix: json['service_prefix']?.toString() ?? '',
      isPriority: json['is_priority'] == 1 || json['is_priority'] == true || json['is_priority'] == '1' || json['is_priority'] == 'true',
      status: json['status']?.toString() ?? 'waiting',
      createdAt: parsedDate,
      trackingToken: json['tracking_token']?.toString(),
      nameBreakdown: parsedNameBreakdown,
      selections: json['selections'] is List ? json['selections'] : null,
      additionalServices: json['additional_services'] is List ? json['additional_services'] : null,
    );
  }
}
