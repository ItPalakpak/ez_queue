import 'dart:convert';

class ApiDepartment {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool allowMultipleServices;
  // CHANGED: Support dynamic multi-service strategy mode
  final String multiServiceMode;
  final String status;
  final String? queueCutoffTime;
  final int dailyTicketLimit;
  final int dailyTicketsUsed;
  final int maxConcurrentQueue;
  final int currentWaiting;
  final bool isQueueOpen;
  final String? queueClosedReason;

  ApiDepartment({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.allowMultipleServices = false,
    this.multiServiceMode = 'disabled',
    this.status = 'active',
    this.queueCutoffTime,
    this.dailyTicketLimit = 0,
    this.dailyTicketsUsed = 0,
    this.maxConcurrentQueue = 50,
    this.currentWaiting = 0,
    this.isQueueOpen = true,
    this.queueClosedReason,
  });

  factory ApiDepartment.fromJson(Map<String, dynamic> json) {
    final allowMult = json['allow_multiple_services'] == true ||
        json['allow_multiple_services'] == 1 ||
        json['allow_multiple_services'] == '1';

    return ApiDepartment(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      allowMultipleServices: allowMult,
      multiServiceMode: json['multi_service_mode']?.toString() ?? (allowMult ? 'independent' : 'disabled'),
      status: json['status']?.toString() ?? 'active',
      queueCutoffTime: json['queue_cutoff_time']?.toString(),
      dailyTicketLimit: json['daily_ticket_limit'] is int
          ? json['daily_ticket_limit']
          : int.tryParse(json['daily_ticket_limit']?.toString() ?? '0') ?? 0,
      dailyTicketsUsed: json['daily_tickets_used'] is int
          ? json['daily_tickets_used']
          : int.tryParse(json['daily_tickets_used']?.toString() ?? '0') ?? 0,
      maxConcurrentQueue: json['max_concurrent_queue'] is int
          ? json['max_concurrent_queue']
          : int.tryParse(json['max_concurrent_queue']?.toString() ?? '50') ?? 50,
      currentWaiting: json['current_waiting'] is int
          ? json['current_waiting']
          : int.tryParse(json['current_waiting']?.toString() ?? '0') ?? 0,
      isQueueOpen:
          json['is_queue_open'] == null ? true :
          json['is_queue_open'] == true ||
          json['is_queue_open'] == 1 ||
          json['is_queue_open'] == '1',
      queueClosedReason: json['queue_closed_reason']?.toString(),
    );
  }
}

class ApiDocumentSubselection {
  final int id;
  final String name;
  final bool requiresAcademicPeriod;
  final List<dynamic> purposes;

  ApiDocumentSubselection({
    required this.id,
    required this.name,
    this.requiresAcademicPeriod = false,
    this.purposes = const [],
  });

  factory ApiDocumentSubselection.fromJson(Map<String, dynamic> json) {
    return ApiDocumentSubselection(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      requiresAcademicPeriod: json['requires_academic_period'] == 1 || json['requires_academic_period'] == true,
      purposes: json['purposes'] is List ? json['purposes'] as List<dynamic> : const [],
    );
  }
}

class ApiServiceDocument {
  final int id;
  final String name;
  final List<ApiDocumentSubselection> subselections;
  final List<dynamic> purposes;

  ApiServiceDocument({
    required this.id,
    required this.name,
    this.subselections = const [],
    this.purposes = const [],
  });

  factory ApiServiceDocument.fromJson(Map<String, dynamic> json) {
    final subs = json['subselections'] as List<dynamic>? ?? [];
    return ApiServiceDocument(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      subselections: subs.map((e) => ApiDocumentSubselection.fromJson(e as Map<String, dynamic>)).toList(),
      purposes: json['purposes'] is List ? json['purposes'] as List<dynamic> : const [],
    );
  }
}

class ApiAcademicYear {
  final int id;
  final String name;
  final String semester;
  final String? endDate;

  ApiAcademicYear({required this.id, required this.name, required this.semester, this.endDate});

  factory ApiAcademicYear.fromJson(Map<String, dynamic> json) {
    return ApiAcademicYear(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
    );
  }
}

class ApiServicePurpose {
  final int id;
  final String name;
  final bool isActive;

  ApiServicePurpose({required this.id, required this.name, this.isActive = true});

  factory ApiServicePurpose.fromJson(Map<String, dynamic> json) {
    return ApiServicePurpose(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] != false,
    );
  }
}

class ApiSubject {
  final int id;
  final String code;
  final String name;
  final int? courseId;

  ApiSubject({required this.id, required this.code, required this.name, this.courseId});

  factory ApiSubject.fromJson(Map<String, dynamic> json) {
    return ApiSubject(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['subject_code']?.toString() ?? '',
      name: json['subject_name']?.toString() ?? '',
      courseId: json['course_id'] is int ? json['course_id'] : int.tryParse(json['course_id']?.toString() ?? ''),
    );
  }
}

class ApiServiceField {
  final int id;
  final String fieldName;
  final String fieldLabel;
  final String fieldType;
  final bool isRequired;
  final List<String> options;
  final Map<String, dynamic> validation;

  ApiServiceField({
    required this.id,
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldType,
    required this.isRequired,
    this.options = const [],
    this.validation = const {},
  });

  factory ApiServiceField.fromJson(Map<String, dynamic> json) {
    return ApiServiceField(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fieldName: json['field_key']?.toString() ?? '',
      fieldLabel: json['field_label']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? 'text',
      isRequired: json['is_required'] == true || json['is_required'] == 1 || json['is_required'] == '1',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      validation: json['validation'] is Map<String, dynamic> ? json['validation'] as Map<String, dynamic> : {},
    );
  }
}

class ApiQueueService {
  final int id;
  final int departmentId;
  final String name;
  final String? description;
  final int estimatedMinutes;
  final List<ApiServiceDocument> documents;
  final List<ApiServicePurpose> purposes;
  final List<ApiServiceField> fields;

  ApiQueueService({
    required this.id,
    required this.departmentId,
    required this.name,
    this.description,
    required this.estimatedMinutes,
    this.documents = const [],
    this.purposes = const [],
    this.fields = const [],
  });

  factory ApiQueueService.fromJson(Map<String, dynamic> json) {
    final docs = json['documents'] as List<dynamic>? ?? [];
    final purps = json['purposes'] as List<dynamic>? ?? [];
    final flds = json['fields'] as List<dynamic>? ?? [];
    
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
      documents: docs.map((e) => ApiServiceDocument.fromJson(e as Map<String, dynamic>)).toList(),
      purposes: purps.map((e) => ApiServicePurpose.fromJson(e as Map<String, dynamic>)).toList(),
      fields: flds.map((e) => ApiServiceField.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ApiServicesResponse {
  final List<ApiQueueService> services;
  final bool allowMultipleServices;
  // CHANGED: Expose dynamic multi-service mode
  final String multiServiceMode;

  ApiServicesResponse({
    required this.services,
    this.allowMultipleServices = false,
    this.multiServiceMode = 'disabled',
  });

  factory ApiServicesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> servicesJson = json['services'] ?? [];
    final allowMult = json['allow_multiple_services'] == true ||
        json['allow_multiple_services'] == 1 ||
        json['allow_multiple_services'] == '1';

    return ApiServicesResponse(
      services: servicesJson
          .map((e) => ApiQueueService.fromJson(e as Map<String, dynamic>))
          .toList(),
      allowMultipleServices: allowMult,
      multiServiceMode: json['multi_service_mode']?.toString() ?? (allowMult ? 'independent' : 'disabled'),
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
  // CHANGED: rate limiting config exposed from admin settings
  final int remoteRateLimitMax;
  final int remoteRateLimitDecayMinutes;
  final Map<String, dynamic>? academicSettings;
  final dynamic clientIdFormats;

  ApiSettings({
    this.enablePriority = true,
    this.remoteQueuingEnabled = true,
    this.systemStatus = 'active',
    this.systemStatusMessage = '',
    this.systemStatusTimestamp,
    this.mobileUrlConfigEnabled = false,
    this.remoteRateLimitMax = 5,
    this.remoteRateLimitDecayMinutes = 10,
    this.academicSettings,
    this.clientIdFormats,
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
      // CHANGED: parse rate limit settings with safe fallbacks
      remoteRateLimitMax:
          int.tryParse(json['remote_rate_limit_max']?.toString() ?? '') ?? 5,
      remoteRateLimitDecayMinutes:
          int.tryParse(json['remote_rate_limit_decay_minutes']?.toString() ?? '') ?? 10,
      academicSettings: json['academic_settings'] as Map<String, dynamic>?,
      clientIdFormats: json['client_id_formats'],
    );
  }

  List<String> getFormatsForRole(String? userType) {
    final defaults = {
      'Student': ['XX-XXXXX', '20XX-XXXXX'],
      'Alumni': ['XX-XXXXX', '20XX-XXXXX'],
      'Faculty/Staff': ['EMP-XXXXX'],
    };

    Map<String, dynamic>? formatsMap;
    if (clientIdFormats is Map<String, dynamic>) {
      formatsMap = clientIdFormats as Map<String, dynamic>;
    } else if (clientIdFormats is String) {
      try {
        formatsMap = jsonDecode(clientIdFormats as String) as Map<String, dynamic>?;
      } catch (_) {}
    }

    final backendKey = switch (userType) {
      'Student' => 'student',
      'Alumni' => 'alumni',
      'Faculty/Staff' => 'faculty',
      _ => 'student',
    };

    if (formatsMap != null && formatsMap[backendKey] is List) {
      final list = (formatsMap[backendKey] as List).map((e) => e.toString()).toList();
      if (list.isNotEmpty) return list;
    }

    return defaults[userType] ?? ['XX-XXXXX', '20XX-XXXXX'];
  }
}

class ApiCourse {
  final int id;
  final String courseCode;
  final String courseName;
  final String? major;
  final String status;
  final String? collegeCode;
  final String? collegeName;

  ApiCourse({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.major,
    this.status = 'active',
    this.collegeCode,
    this.collegeName,
  });

  factory ApiCourse.fromJson(Map<String, dynamic> json) {
    String? colName;
    if (json['college'] is Map<String, dynamic>) {
      colName = json['college']['college_name']?.toString();
    }
    return ApiCourse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      courseCode: json['course_code']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
      major: json['major']?.toString(),
      status: json['status']?.toString() ?? 'active',
      collegeCode: json['college_code']?.toString(),
      collegeName: colName,
    );
  }
}

class ApiDisplayStation {
  final int stationId;
  final String stationName;
  final String? currentTicket;
  final String? serviceName;
  final String? clientName;
  final String status;
  final List<int> waitingIds;

  ApiDisplayStation({
    required this.stationId,
    required this.stationName,
    this.currentTicket,
    this.serviceName,
    this.clientName,
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
      clientName: json['client_name']?.toString(),
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
  final String? clientName;
  final String? course;
  final bool isPriority;
  final String waitTime;

  ApiDisplayTicket({
    required this.id,
    required this.ticketNumber,
    required this.serviceName,
    this.clientName,
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
      clientName: json['client_name']?.toString(),
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
