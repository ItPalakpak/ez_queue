/// Model class for queue ticket information.
class QueueTicket {
  final String ticketNumber;
  final String department;
  final List<String> services;
  final String userType;
  final String? idNumber;
  final String fullName;
  final String email;
  final bool isPWD;
  final String? pwdSpecification;
  final DateTime createdAt;
  final int queuePosition;
  final int estimatedWaitMinutes;

  const QueueTicket({
    required this.ticketNumber,
    required this.department,
    required this.services,
    required this.userType,
    this.idNumber,
    required this.fullName,
    required this.email,
    this.isPWD = false,
    this.pwdSpecification,
    required this.createdAt,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
  });
}

