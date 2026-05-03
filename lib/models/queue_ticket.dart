/// Model class for queue ticket information.
class QueueTicket {
  final int id;
  final String ticketNumber;
  final String studentName;
  final String userType;
  final String? studentId;
  final String? employeeId;
  final String? phone;
  final String? email;
  final String? course;
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

  const QueueTicket({
    required this.id,
    required this.ticketNumber,
    required this.studentName,
    required this.userType,
    this.studentId,
    this.employeeId,
    this.phone,
    this.email,
    this.course,
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
  });

  factory QueueTicket.fromJson(Map<String, dynamic> json) {
    return QueueTicket(
      id: json['id'],
      ticketNumber: json['ticket_number'],
      studentName: json['student_name'] ?? 'Unknown',
      userType: json['user_type'] ?? 'student',
      studentId: json['student_id'],
      employeeId: json['employee_id'],
      phone: json['phone'],
      email: json['email'],
      course: json['course'],
      purpose: json['purpose'],
      quantity: json['quantity'] ?? 1,
      departmentId: json['department_id'] ?? 1, // Fallback to 1 if it's an old cached ticket payload on user device
      departmentName: json['department_name'] ?? '',
      departmentCode: json['department_code'] ?? '',
      serviceName: json['service_name'] ?? '',
      servicePrefix: json['service_prefix'] ?? '',
      isPriority: json['is_priority'] == 1 || json['is_priority'] == true,
      status: json['status'] ?? 'waiting',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now(),
    );
  }
}
