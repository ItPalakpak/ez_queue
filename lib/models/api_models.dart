class ApiDepartment {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool allowMultipleServices;
  final String status;

  ApiDepartment({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.allowMultipleServices = false,
    this.status = 'active',
  });

  factory ApiDepartment.fromJson(Map<String, dynamic> json) {
    return ApiDepartment(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      allowMultipleServices:
          json['allow_multiple_services'] == true ||
          json['allow_multiple_services'] == 1 ||
          json['allow_multiple_services'] == '1',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class ApiQueueService {
  final int id;
  final int departmentId;
  final String name;
  final String? description;
  final int estimatedMinutes;

  ApiQueueService({
    required this.id,
    required this.departmentId,
    required this.name,
    this.description,
    required this.estimatedMinutes,
  });

  factory ApiQueueService.fromJson(Map<String, dynamic> json) {
    return ApiQueueService(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      departmentId: json['department_id'] is int
          ? json['department_id']
          : int.tryParse(json['department_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unknown Service',
      description: json['description']?.toString(),
      estimatedMinutes: json['estimated_minutes'] is int
          ? json['estimated_minutes']
          : int.tryParse(json['estimated_minutes']?.toString() ?? '0') ?? 0,
    );
  }
}

class ApiServicesResponse {
  final List<ApiQueueService> services;
  final bool allowMultipleServices;

  ApiServicesResponse({
    required this.services,
    this.allowMultipleServices = false,
  });

  factory ApiServicesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> servicesJson = json['services'] ?? [];
    return ApiServicesResponse(
      services: servicesJson
          .map((e) => ApiQueueService.fromJson(e as Map<String, dynamic>))
          .toList(),
      allowMultipleServices:
          json['allow_multiple_services'] == true ||
          json['allow_multiple_services'] == 1 ||
          json['allow_multiple_services'] == '1',
    );
  }
}

class ApiSettings {
  final bool enablePriority;
  final bool remoteQueuingEnabled;
  final String systemStatus;
  final String systemStatusMessage;
  final String? systemStatusTimestamp;
  final bool mobileUrlConfigEnabled;

  ApiSettings({
    this.enablePriority = true,
    this.remoteQueuingEnabled = true,
    this.systemStatus = 'active',
    this.systemStatusMessage = '',
    this.systemStatusTimestamp,
    this.mobileUrlConfigEnabled = false,
  });

  factory ApiSettings.fromJson(Map<String, dynamic> json) {
    return ApiSettings(
      enablePriority:
          json['enable_priority'] == '1' || json['enable_priority'] == true,
      remoteQueuingEnabled: json['remote_queuing_enabled'] == null
          ? true
          : json['remote_queuing_enabled'] == '1' ||
                json['remote_queuing_enabled'] == true,
      systemStatus: json['system_status']?.toString() ?? 'active',
      systemStatusMessage: json['system_status_message']?.toString() ?? '',
      systemStatusTimestamp: json['system_status_timestamp']?.toString(),
      mobileUrlConfigEnabled:
          json['mobile_url_config_enabled'] == '1' ||
          json['mobile_url_config_enabled'] == true,
    );
  }
}

class ApiCourse {
  final int id;
  final String courseCode;
  final String courseName;
  final String status;

  ApiCourse({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.status = 'active',
  });

  factory ApiCourse.fromJson(Map<String, dynamic> json) {
    return ApiCourse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      courseCode: json['course_code']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class ApiDisplayStation {
  final int stationId;
  final String stationName;
  final String? currentTicket;
  final String? serviceName;
  final String? studentName;
  final String status;
  final List<int> waitingIds;

  ApiDisplayStation({
    required this.stationId,
    required this.stationName,
    this.currentTicket,
    this.serviceName,
    this.studentName,
    required this.status,
    this.waitingIds = const [],
  });

  factory ApiDisplayStation.fromJson(Map<String, dynamic> json) {
    return ApiDisplayStation(
      stationId: json['station_id'] is int
          ? json['station_id']
          : int.tryParse(json['station_id']?.toString() ?? '0') ?? 0,
      stationName: json['station_name']?.toString() ?? '',
      currentTicket: json['current_ticket']?.toString(),
      serviceName: json['service_name']?.toString(),
      studentName: json['student_name']?.toString(),
      status: json['status']?.toString() ?? 'available',
      waitingIds:
          (json['waiting_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

class ApiDisplayTicket {
  final int id;
  final String ticketNumber;
  final String serviceName;
  final String? studentName;
  final String? course;
  final bool isPriority;
  final String waitTime;

  ApiDisplayTicket({
    required this.id,
    required this.ticketNumber,
    required this.serviceName,
    this.studentName,
    this.course,
    required this.isPriority,
    required this.waitTime,
  });

  factory ApiDisplayTicket.fromJson(Map<String, dynamic> json) {
    return ApiDisplayTicket(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      studentName: json['student_name']?.toString(),
      course: json['course']?.toString(),
      isPriority:
          json['is_priority'] == true ||
          json['is_priority'] == 1 ||
          json['is_priority'] == '1',
      waitTime: (json['wait_minutes'] ?? json['wait_time'])?.toString() ?? '',
    );
  }
}

class ApiDisplayData {
  final String departmentName;
  final List<ApiDisplayStation> stations;
  final List<ApiDisplayTicket> waiting;
  final int totalWaiting;
  final int totalServing;
  final int totalStations;

  ApiDisplayData({
    required this.departmentName,
    required this.stations,
    required this.waiting,
    required this.totalWaiting,
    required this.totalServing,
    required this.totalStations,
  });

  factory ApiDisplayData.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return ApiDisplayData(
      departmentName: json['department_name']?.toString() ?? '',
      stations:
          (json['stations'] as List<dynamic>?)
              ?.map(
                (e) => ApiDisplayStation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      waiting:
          (json['waiting'] as List<dynamic>?)
              ?.map((e) => ApiDisplayTicket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalWaiting: stats['total_waiting'] is int
          ? stats['total_waiting']
          : int.tryParse(stats['total_waiting']?.toString() ?? '0') ?? 0,
      totalServing: stats['total_serving'] is int
          ? stats['total_serving']
          : int.tryParse(stats['total_serving']?.toString() ?? '0') ?? 0,
      totalStations: stats['total_stations'] is int
          ? stats['total_stations']
          : int.tryParse(stats['total_stations']?.toString() ?? '0') ?? 0,
    );
  }
}
