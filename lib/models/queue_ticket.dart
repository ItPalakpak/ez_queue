import 'package:ez_queue/models/queue_form_data.dart';

/// Model class for queue ticket information.
class QueueTicket {
  final String ticketNumber;
  final String department;
  final List<String> services;
  final String? purpose;
  final List<ServiceItem> items;
  final String userType;
  final String? idNumber;
  final String? courseProgram;
  final String fullName;
  final String email;
  final String? contactNumber;
  final bool isPWD;
  final String? pwdSpecification;
  final DateTime createdAt;
  final int queuePosition;
  final int estimatedWaitMinutes;

  const QueueTicket({
    required this.ticketNumber,
    required this.department,
    required this.services,
    this.purpose,
    this.items = const [],
    required this.userType,
    this.idNumber,
    this.courseProgram,
    required this.fullName,
    required this.email,
    this.contactNumber,
    this.isPWD = false,
    this.pwdSpecification,
    required this.createdAt,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
  });
}
