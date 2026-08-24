import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/widgets/ez_form_text_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';
import 'package:ez_queue/widgets/ez_dialog.dart';
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/models/api_models.dart';
import 'package:ez_queue/services/api_service.dart';

/// Identity information page.
/// Step 2: Captures Full Name, ID Number (if applicable), and Course/Program.
/// Includes QR code scanning feature like React Kiosk.
class IdentityInformationPage extends ConsumerStatefulWidget {
  const IdentityInformationPage({super.key});

  @override
  ConsumerState<IdentityInformationPage> createState() =>
      _IdentityInformationPageState();
}

class _IdentityInformationPageState
    extends ConsumerState<IdentityInformationPage> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _selectedCourseId;
  String? _selectedCourseProgram;
  String? _selectedMajor;
  String? _selectedYearLevel;
  String? _selectedStanding;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _suffixController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  /// Check if selected user type requires ID number.
  bool _requiresIdNumber(String? userType) {
    return userType != null &&
        ['Student', 'Faculty/Staff', 'Alumni'].contains(userType);
  }

  /// Validate ID value against configured role format patterns.
  bool _validateIdFormat(String idVal, List<String> allowedFormats) {
    if (idVal.isEmpty || allowedFormats.isEmpty) return true;
    for (final fmt in allowedFormats) {
      final cleanFmt = fmt.trim();
      if (cleanFmt.isEmpty) continue;
      RegExp regex;
      if (cleanFmt.startsWith('/') || cleanFmt.startsWith('^')) {
        final pattern = cleanFmt.startsWith('/')
            ? cleanFmt.substring(1, cleanFmt.length - 1)
            : cleanFmt;
        regex = RegExp(pattern, caseSensitive: false);
      } else {
        final pattern = RegExp.escape(cleanFmt)
            .replaceAll('X', r'\d')
            .replaceAll('x', r'\d');
        regex = RegExp('^$pattern\$', caseSensitive: false);
      }
      if (regex.hasMatch(idVal.trim())) {
        return true;
      }
    }
    return false;
  }

  /// Check if selected user type requires course/program.
  bool _requiresCourseProgram(String? userType) {
    return userType != null &&
        ['Student', 'Faculty/Staff', 'Alumni', 'Visitor'].contains(userType);
  }

  /// Check if selected user type has optional course/program.
  bool _isCourseOptional(String? userType) {
    return userType == 'Visitor';
  }

  String _idNumberHintText(String? userType) {
    return switch (userType) {
      'Student' => 'Please enter your student ID of this institution',
      'Faculty/Staff' => 'Please enter your Employee ID of this institution',
      'Alumni' => 'Please enter your alumni ID of this institution',
      _ => 'Enter your institution ID number',
    };
  }

  String _idNumberLabel(String? userType) {
    return switch (userType) {
      'Student' => 'Student ID',
      'Faculty/Staff' => 'Employee ID',
      'Alumni' => 'Alumni ID',
      _ => 'ID Number',
    };
  }

  String? _courseHelperText(String? userType) {
    return switch (userType) {
      'Alumni' =>
        'please choose the course that you have finished here in this institution',
      'Faculty/Staff' =>
        'please choose the course that you work at here in this institution',
      'Visitor' =>
        'please choose the course that connects to your purpose for coming here in this institution',
      _ => null,
    };
  }

  String? _lastPopulatedId;

  String _getBackendRole(String? userType) {
    return switch (userType) {
      'Student' => 'student',
      'Alumni' => 'alumni',
      'Faculty/Staff' => 'faculty',
      'Visitor' => 'visitor',
      _ => 'student',
    };
  }

  Future<void> _autoPopulateFromArchive(String idVal, String userTypeBackend) async {
    final cleanId = idVal.trim();
    if (cleanId.isEmpty || _lastPopulatedId == cleanId) return;
    try {
      final profile = await apiService.lookupClientProfile(
        idNumber: cleanId,
        userType: userTypeBackend,
      );
      if (profile == null) return;

      _lastPopulatedId = cleanId;

      final nameBreakdown = profile['name_breakdown'] as Map<String, dynamic>?;
      if (nameBreakdown != null) {
        if (nameBreakdown['last_name'] != null && (nameBreakdown['last_name'] as String).isNotEmpty) {
          _lastNameController.text = nameBreakdown['last_name'];
        }
        if (nameBreakdown['first_name'] != null && (nameBreakdown['first_name'] as String).isNotEmpty) {
          _firstNameController.text = nameBreakdown['first_name'];
        }
        if (nameBreakdown['middle_name'] != null) {
          _middleNameController.text = nameBreakdown['middle_name'];
        }
        if (nameBreakdown['suffix'] != null) {
          _suffixController.text = nameBreakdown['suffix'];
        }
      } else if (profile['client_name'] != null) {
        _firstNameController.text = profile['client_name'];
      }

      if (profile['course_id'] != null) {
        setState(() {
          _selectedCourseId = profile['course_id'] as int?;
          if (profile['course'] != null) {
            _selectedCourseProgram = profile['course'];
          }
          if (profile['major'] != null) {
            _selectedMajor = profile['major']?.toString();
          }
        });
      }

      if (profile['major'] != null && _selectedMajor == null) {
        setState(() {
          _selectedMajor = profile['major']?.toString();
        });
      }

      if (profile['year_level'] != null) {
        setState(() {
          _selectedYearLevel = profile['year_level'];
        });
      }

      if (profile['standing'] != null) {
        setState(() {
          _selectedStanding = profile['standing'];
        });
      }

      final contact = <String, String>{};
      if (profile['phone'] != null && (profile['phone'] as String).isNotEmpty) {
        contact['phone'] = profile['phone'];
      }
      if (profile['email'] != null && (profile['email'] as String).isNotEmpty) {
        contact['email'] = profile['email'];
      }

      if (contact.isNotEmpty) {
        _storeScannedContact(contact);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archive Data Found: Identity and contact details auto-populated'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (_) {
      // Ignore lookup error
    }
  }

  void _onIdNumberChanged(String val, List<String> allowedFormats, String userTypeBackend) {
    _debounceTimer?.cancel();
    if (val.trim().isEmpty) {
      _lastPopulatedId = null;
      return;
    }
    if (_lastPopulatedId == val.trim() || !_validateIdFormat(val, allowedFormats)) return;
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _autoPopulateFromArchive(val, userTypeBackend);
    });
  }

  /// Strip HTML tags and truncate to a max length — CHANGED: security hardening for QR data.
  String _sanitize(String input, int maxLength) {
    // Strip HTML tags
    final stripped = input.replaceAll(RegExp(r'<[^>]*>'), '');
    // Truncate to max length
    return stripped.length > maxLength
        ? stripped.substring(0, maxLength)
        : stripped;
  }

  /// Parse QR code data and populate fields.
  void _parseQRData(String qrData, List<ApiCourse> courses) {
    final lines = qrData.split(RegExp(r'\r?\n'));
    final data = <String, String>{};

    for (final line in lines) {
      final idx = line.indexOf(':');
      if (idx > -1) {
        final key = line.substring(0, idx).trim();
        final val = line.substring(idx + 1).trim();
        data[key] = val;
      }
    }

    var hasValidData = false;
    final formData = ref.read(queueFormProvider);
    final userType = formData.userType;

    // Parse explicitly structured Name Parts if available
    if (data['Last Name'] != null) {
      setState(() => _lastNameController.text = _sanitize(data['Last Name']!, 100));
      hasValidData = true;
    }
    if (data['First Name'] != null) {
      setState(() => _firstNameController.text = _sanitize(data['First Name']!, 100));
      hasValidData = true;
    }
    if (data['Middle Name'] != null) {
      setState(() => _middleNameController.text = _sanitize(data['Middle Name']!, 100));
      hasValidData = true;
    }
    if (data['Suffix'] != null) {
      setState(() => _suffixController.text = _sanitize(data['Suffix']!, 50));
      hasValidData = true;
    }

    // Fallback logic for old QR codes
    if (data['Name'] != null && data['Name']!.isNotEmpty && data['Last Name'] == null && data['First Name'] == null) {
      final sanitizedName = _sanitize(data['Name']!, 255);
      final parts = sanitizedName.split(',');
      setState(() {
        if (parts.length > 1) {
          _lastNameController.text = parts[0].trim();
          final remaining = parts[1].trim().split(' ');
          _firstNameController.text = remaining.isNotEmpty ? remaining[0] : '';
          if (remaining.length > 1) {
            _middleNameController.text = remaining.sublist(1).join(' ');
          }
        } else {
          _firstNameController.text = sanitizedName.trim();
        }
      });
      hasValidData = true;
    }

    // Parse ID based on user type
    if (userType == 'Student' && data['Student ID'] != null) {
      setState(() {
        _idNumberController.text = _sanitize(data['Student ID']!, 50);
      });
      hasValidData = true;
    } else if (userType == 'Alumni' && data['Alumni ID'] != null) {
      setState(() {
        _idNumberController.text = _sanitize(data['Alumni ID']!, 50);
      });
      hasValidData = true;
    } else if (userType == 'Faculty/Staff' &&
        (data['Staff/Faculty ID'] != null || data['Employee ID'] != null)) {
      setState(() {
        _idNumberController.text = _sanitize(
          data['Staff/Faculty ID'] ?? data['Employee ID']!,
          50,
        );
      });
      hasValidData = true;
    }

    // Parse Course
    if (data['Course'] != null && courses.isNotEmpty) {
      final courseName = data['Course']!.toLowerCase();
      final matchedCourse = courses.firstWhere(
        (c) =>
            c.courseName.toLowerCase() == courseName ||
            c.courseCode.toLowerCase() == courseName ||
            '${c.courseCode} - ${c.courseName}'.toLowerCase() == courseName,
        orElse: () => courses.first,
      );
      if (matchedCourse != courses.first ||
          '${matchedCourse.courseCode} - ${matchedCourse.courseName}'
                  .toLowerCase() ==
              courseName) {
        setState(() {
          _selectedCourseId = matchedCourse.id;
          _selectedCourseProgram =
              '${matchedCourse.courseCode} - ${matchedCourse.courseName}';
        });
        hasValidData = true;
      }
    }

    if (data['Major'] != null && data['Major']!.isNotEmpty) {
      setState(() {
        _selectedMajor = _sanitize(data['Major']!, 100);
      });
      hasValidData = true;
    }

    // Store contact info for next step
    final contact = <String, String>{};
    if (data['Phone'] != null && data['Phone']!.isNotEmpty) {
      String phone = data['Phone']!;
      // Remove +63 or 63 prefix if present
      if (phone.startsWith('+63') && phone.length > 3) {
        phone = phone.substring(3);
      } else if (phone.startsWith('63') && phone.length > 2) {
        phone = phone.substring(2);
      }
      // Remove leading 0 if present
      if (phone.startsWith('0') && phone.length > 1) {
        phone = phone.substring(1);
      }
      // Format as 000 000 0000 (10 digits with spaces)
      if (phone.length == 10) {
        phone =
            '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6, 10)}';
      }
      contact['phone'] = phone;
      hasValidData = true;
    }
    if (data['Email'] != null && data['Email']!.isNotEmpty) {
      contact['email'] = data['Email']!;
      hasValidData = true;
    }

    if (contact.isNotEmpty) {
      _storeScannedContact(contact);
    }

    final scannedId = _idNumberController.text.trim();
    if (scannedId.isNotEmpty) {
      _autoPopulateFromArchive(scannedId, _getBackendRole(userType));
    }

    // Show result
    if (hasValidData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Scanned: Identity details populated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan Failed: QR code contained no valid user details'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Store scanned contact info for Contact page.
  Future<void> _storeScannedContact(Map<String, String> contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scanned_contact', contact.toString());
  }

  /// Show QR scanner dialog.
  void _showQRScanner(List<ApiCourse> courses) {
    showDialog(
      context: context,
      builder: (context) => EZDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Scan QR Code'),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: Column(
          children: [
            SizedBox(
              height: 300,
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      Navigator.of(context).pop();
                      _parseQRData(barcode.rawValue!, courses);
                      return;
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: EZSpacing.md),
            const Text('Point camera at a student/faculty ID QR code'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(queueFormProvider);
    final userType = formData.userType;

    if (userType == null) {
      return const Scaffold(
        body: Center(child: Text('Please select a user type first.')),
      );
    }

    if (formData.nameBreakdown != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_lastNameController.text.isEmpty) _lastNameController.text = formData.nameBreakdown!['last_name'] ?? '';
          if (_firstNameController.text.isEmpty) _firstNameController.text = formData.nameBreakdown!['first_name'] ?? '';
          if (_middleNameController.text.isEmpty) _middleNameController.text = formData.nameBreakdown!['middle_name'] ?? '';
          if (_suffixController.text.isEmpty) _suffixController.text = formData.nameBreakdown!['suffix'] ?? '';
        }
      });
    } else if (formData.fullName != null && _firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
      // Legacy fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           _firstNameController.text = formData.fullName!;
        }
      });
    }

    if (formData.idNumber != null && _idNumberController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _idNumberController.text = formData.idNumber!;
        }
      });
    }

    if (formData.courseId != null && _selectedCourseId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCourseId = formData.courseId;
            _selectedCourseProgram = formData.courseProgram;
          });
        }
      });
    }

    if (formData.yearLevel != null && _selectedYearLevel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedYearLevel = formData.yearLevel;
          });
        }
      });
    }

    if (formData.standing != null && _selectedStanding == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedStanding = formData.standing;
          });
        }
      });
    }

    if (formData.major != null && _selectedMajor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedMajor = formData.major;
          });
        }
      });
    }

    final coursesAsync = ref.watch(apiCoursesProvider);
    final settingsAsync = ref.watch(apiSettingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const TopNavBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(apiCoursesProvider);
                    ref.invalidate(apiSettingsProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(EZSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step header - icon, text, and QR button in one row
                          Container(
                            margin: const EdgeInsets.only(bottom: EZSpacing.xl),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🪪',
                                      style: TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: EZSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Identity',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: EZSpacing.xs),
                                      Text(
                                        'Tell us who you are',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // QR scan button on same row as header
                                coursesAsync.when(
                                  data: (courses) => IconButton(
                                    onPressed: () => _showQRScanner(courses),
                                    icon: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    tooltip: 'Scan QR Code',
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),

                          // ID Number input (shown for student, alumni, faculty)
                          if (_requiresIdNumber(userType)) ...[
                            Text(
                              _idNumberLabel(userType),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: EZSpacing.md),
                            EZFormTextField(
                              isRequired: true,
                              controller: _idNumberController,
                              hintText: _idNumberHintText(userType),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLength: 50,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9\-]'),
                                ),
                              ],
                              onChanged: (val) {
                                final settings = settingsAsync.asData?.value;
                                final formats = settings?.getFormatsForRole(userType) ??
                                    (userType == 'Faculty/Staff'
                                        ? ['EMP-XXXXX']
                                        : ['XX-XXXXX', '20XX-XXXXX']);
                                _onIdNumberChanged(val, formats, _getBackendRole(userType));
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your ${_idNumberLabel(userType).toLowerCase()}';
                                }
                                final settings = settingsAsync.asData?.value;
                                final formats = settings?.getFormatsForRole(userType) ??
                                    (userType == 'Faculty/Staff'
                                        ? ['EMP-XXXXX']
                                        : ['XX-XXXXX', '20XX-XXXXX']);
                                if (!_validateIdFormat(value.trim(), formats)) {
                                  return 'Invalid format. Expected: ${formats.join(' or ')}';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: EZSpacing.xs),
                            Builder(
                              builder: (context) {
                                final settings = settingsAsync.asData?.value;
                                final formats = settings?.getFormatsForRole(userType) ??
                                    (userType == 'Faculty/Staff'
                                        ? ['EMP-XXXXX']
                                        : ['XX-XXXXX', '20XX-XXXXX']);
                                if (formats.isEmpty) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 2,
                                    bottom: EZSpacing.md,
                                  ),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        'Allowed Formats:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                      ),
                                      ...formats.map(
                                        (fmt) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.15),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            fmt,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: EZSpacing.lg),
                          ],

                          // Name inputs
                          Text(
                            'Last Name *',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.sm),
                          EZFormTextField(
                            isRequired: true,
                            controller: _lastNameController,
                            hintText: 'Enter your last name',
                            textInputAction: TextInputAction.next,
                            maxLength: 100,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s\-\.]'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: EZSpacing.lg),

                          Text(
                            'First Name *',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.sm),
                          EZFormTextField(
                            isRequired: true,
                            controller: _firstNameController,
                            hintText: 'Enter your first name',
                            textInputAction: TextInputAction.next,
                            maxLength: 100,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s\-\.]'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: EZSpacing.lg),

                          Text(
                            'Middle Name',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.sm),
                          EZFormTextField(
                            controller: _middleNameController,
                            hintText: 'Enter your middle name',
                            textInputAction: TextInputAction.next,
                            maxLength: 100,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s\-\.]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: EZSpacing.lg),

                          Text(
                            'Suffix',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.sm),
                          EZFormTextField(
                            controller: _suffixController,
                            hintText: 'e.g., Jr., III',
                            textInputAction: TextInputAction.next,
                            maxLength: 50,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s\-\.]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: EZSpacing.xxl),

                          // Course/Program combobox
                          if (_requiresCourseProgram(userType)) ...[
                            Text(
                              _isCourseOptional(userType)
                                  ? 'Course / Program (Optional)'
                                  : 'Course / Program *',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: EZSpacing.md),
                            coursesAsync.when(
                              data: (courses) {
                                // CHANGED: compute effective value immediately — if the selected
                                // course was deactivated or its college was deactivated, treat
                                // it as null so the dropdown never gets an invalid value.
                                final effectiveCourseId =
                                    (_selectedCourseId != null &&
                                        courses.any(
                                          (c) => c.id == _selectedCourseId,
                                        ))
                                    ? _selectedCourseId
                                    : null;
                                // Clear stale state in the background so form submission
                                // doesn't send a stale courseId either.
                                if (_selectedCourseId != null &&
                                    effectiveCourseId == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedCourseId = null;
                                        _selectedCourseProgram = null;
                                      });
                                    }
                                  });
                                }
                                final selectedCourseObj = effectiveCourseId != null
                                    ? courses.firstWhere(
                                        (c) => c.id == effectiveCourseId,
                                        orElse: () => courses.first,
                                      )
                                    : null;
                                final majorsList = (selectedCourseObj?.major != null &&
                                        selectedCourseObj!.major!.trim().isNotEmpty)
                                    ? selectedCourseObj.major!
                                        .split(',')
                                        .map((m) => m.trim())
                                        .where((m) => m.isNotEmpty)
                                        .toList()
                                    : <String>[];

                                if (_selectedMajor != null &&
                                    (majorsList.isEmpty || !majorsList.contains(_selectedMajor))) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedMajor = null;
                                      });
                                    }
                                  });
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    EZInputField(
                                      isRequired: !_isCourseOptional(userType),
                                      child: DropdownButtonFormField<int>(
                                        initialValue: effectiveCourseId,
                                        decoration:
                                            ThemeHelpers.dropdownInputDecoration(
                                              labelText: 'Course / Program',
                                              hintText: 'Select your course',
                                              prefixIcon: const Icon(
                                                Icons.school_outlined,
                                              ),
                                            ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('-- Select your course --'),
                                          ),
                                          ...courses.map((course) {
                                            return DropdownMenuItem<int>(
                                              value: course.id,
                                              child: Text(
                                                '${course.courseCode} - ${course.courseName}',
                                              ),
                                            );
                                          }),
                                        ],
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedCourseId = value;
                                            if (value != null) {
                                              final c = courses.firstWhere(
                                                (c) => c.id == value,
                                              );
                                              _selectedCourseProgram =
                                                  '${c.courseCode} - ${c.courseName}';
                                            } else {
                                              _selectedCourseProgram = null;
                                            }
                                          });
                                        },
                                        isExpanded: true,
                                        dropdownColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        menuMaxHeight: 300,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    if (majorsList.isNotEmpty) ...[
                                      const SizedBox(height: EZSpacing.lg),
                                      Text(
                                        _isCourseOptional(userType)
                                            ? 'Major / Specialization (Optional)'
                                            : 'Major / Specialization *',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: EZSpacing.md),
                                      EZInputField(
                                        isRequired: !_isCourseOptional(userType),
                                        child: DropdownButtonFormField<String>(
                                          initialValue: (_selectedMajor != null &&
                                                  majorsList.contains(_selectedMajor))
                                              ? _selectedMajor
                                              : null,
                                          decoration:
                                              ThemeHelpers.dropdownInputDecoration(
                                                labelText: 'Major / Specialization',
                                                hintText: 'Select your major',
                                                prefixIcon: const Icon(
                                                  Icons.bookmark_outline,
                                                ),
                                              ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text(
                                                '-- Select Major / Specialization --',
                                              ),
                                            ),
                                            ...majorsList.map((m) => DropdownMenuItem<String>(
                                              value: m,
                                              child: Text(m),
                                            )),
                                          ],
                                          onChanged: (String? val) {
                                            setState(() {
                                              _selectedMajor = val;
                                            });
                                          },
                                          validator: (val) {
                                            if (!_isCourseOptional(userType) &&
                                                majorsList.isNotEmpty &&
                                                (val == null || val.trim().isEmpty)) {
                                              return 'Please select your major / specialization';
                                            }
                                            return null;
                                          },
                                          isExpanded: true,
                                          dropdownColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          menuMaxHeight: 300,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, st) => Center(
                                child: Text('Failed to load courses: $e'),
                              ),
                            ),
                            if (_courseHelperText(userType) != null) ...[
                              const SizedBox(height: EZSpacing.sm),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: EZSpacing.xs,
                                ),
                                child: Text(
                                  _courseHelperText(userType)!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ),
                            ],
                            const SizedBox(height: EZSpacing.xxl),
                          ],

                          // Year Level and Standing for Students
                          if (userType == 'Student') ...[
                            settingsAsync.when(
                              data: (settings) {
                                final academicSettings =
                                    settings.academicSettings;
                                if (academicSettings == null) {
                                  return const SizedBox.shrink();
                                }

                                final format =
                                    (academicSettings['year_level_format']
                                                as String? ??
                                            'normal')
                                        .toLowerCase();
                                List<String> yearLevels;
                                if (format == 'numerals') {
                                  yearLevels = ['I', 'II', 'III', 'IV'];
                                } else if (format == 'title') {
                                  yearLevels = [
                                    'Freshman',
                                    'Sophomore',
                                    'Junior',
                                    'Senior',
                                  ];
                                } else {
                                  yearLevels = [
                                    '1st Year',
                                    '2nd Year',
                                    '3rd Year',
                                    '4th Year',
                                  ];
                                }

                                final requireStanding =
                                    academicSettings['require_standing'] ==
                                        true ||
                                    academicSettings['require_standing'] == 1 ||
                                    academicSettings['require_standing'] == '1';
                                final standingsList =
                                    (academicSettings['standings']
                                            as List<dynamic>?)
                                        ?.map((e) => e.toString())
                                        .toList() ??
                                    [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Year Level',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: EZSpacing.md),
                                    EZInputField(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedYearLevel,
                                        decoration:
                                            ThemeHelpers.dropdownInputDecoration(
                                              labelText: 'Year Level',
                                              hintText:
                                                  '-- Select Year Level --',
                                            ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text(
                                              '-- Select Year Level --',
                                            ),
                                          ),
                                          ...yearLevels.map(
                                            (yl) => DropdownMenuItem<String>(
                                              value: yl,
                                              child: Text(yl),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedYearLevel = value;
                                          });
                                        },
                                        isExpanded: true,
                                        dropdownColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: EZSpacing.xxl),

                                    if (requireStanding &&
                                        standingsList.isNotEmpty) ...[
                                      Text(
                                        'Standing',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: EZSpacing.md),
                                      EZInputField(
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _selectedStanding,
                                          decoration:
                                              ThemeHelpers.dropdownInputDecoration(
                                                labelText: 'Standing',
                                                hintText:
                                                    '-- Select Standing --',
                                              ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text(
                                                '-- Select Standing --',
                                              ),
                                            ),
                                            ...standingsList.map(
                                              (s) => DropdownMenuItem<String>(
                                                value: s,
                                                child: Text(s),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedStanding = value;
                                            });
                                          },
                                          isExpanded: true,
                                          dropdownColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: EZSpacing.xxl),
                                    ],
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],

                          // Navigation buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: EZButton(
                                  isSecondary: true,
                                  onPressed: () => context.pop(),
                                  child: const Text('Back'),
                                ),
                              ),
                              const SizedBox(width: EZSpacing.md),
                              Expanded(
                                flex: 2,
                                child: EZButton(
                                  onPressed: () => _handleContinue(userType),
                                  child: const Text('Continue'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // QR button moved to header row
        ],
      ),
    );
  }

  /// Handle continue button press.
  void _handleContinue(String userType) {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isCourseOptional(userType) &&
          _requiresCourseProgram(userType) &&
          _selectedCourseProgram == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your course/program.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final lastName = _lastNameController.text.trim();
      final firstName = _firstNameController.text.trim();
      final middleName = _middleNameController.text.trim();
      final suffix = _suffixController.text.trim();

      String generatedFullName = '$lastName, $firstName';
      if (middleName.isNotEmpty) generatedFullName += ' $middleName';
      if (suffix.isNotEmpty) generatedFullName += ' $suffix';

      ref
          .read(queueFormProvider.notifier)
          .updateIdentityInfo(
            fullName: generatedFullName,
            nameBreakdown: {
              'last_name': lastName,
              'first_name': firstName,
              if (middleName.isNotEmpty) 'middle_name': middleName,
              if (suffix.isNotEmpty) 'suffix': suffix,
            },
            idNumber: _idNumberController.text.trim().isEmpty
                ? null
                : _idNumberController.text.trim(),
            courseId: _selectedCourseId,
            courseProgram: _selectedCourseProgram,
            major: _selectedMajor,
            yearLevel: _selectedYearLevel,
            standing: _selectedStanding,
          );

      context.push('/contact-information');
    }
  }
}
