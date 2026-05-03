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
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/models/api_models.dart';

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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _selectedCourseId;
  String? _selectedCourseProgram;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  /// Check if selected user type requires ID number.
  bool _requiresIdNumber(String? userType) {
    return userType != null &&
        ['Student', 'Faculty/Staff', 'Alumni'].contains(userType);
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

    // Parse Name — CHANGED: truncate and strip HTML tags for security
    if (data['Name'] != null && data['Name']!.isNotEmpty) {
      setState(() {
        _fullNameController.text = _sanitize(data['Name']!, 255);
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
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(EZSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan QR Code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Scanner
              Expanded(
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
              // Instructions
              Padding(
                padding: const EdgeInsets.all(EZSpacing.md),
                child: Text(
                  'Point camera at a student/faculty ID QR code',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
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

    if (formData.fullName != null && _fullNameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fullNameController.text = formData.fullName!;
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

    final coursesAsync = ref.watch(apiCoursesProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const TopNavBar(),
              Expanded(
                child: SingleChildScrollView(
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            controller: _idNumberController,
                            hintText: _idNumberHintText(userType),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLength: 50,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\-]'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your ${_idNumberLabel(userType).toLowerCase()}';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: EZSpacing.xxl),
                        ],

                        // Full name input
                        Text(
                          'Full Name *',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: EZSpacing.md),
                        EZFormTextField(
                          controller: _fullNameController,
                          hintText: 'Enter your full name',
                          textInputAction: TextInputAction.next,
                          maxLength: 255,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
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
                              return EZInputField(
                                child: DropdownButtonFormField<int>(
                                  value: effectiveCourseId,
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

      ref
          .read(queueFormProvider.notifier)
          .updateIdentityInfo(
            fullName: _fullNameController.text.trim(),
            idNumber: _idNumberController.text.trim().isEmpty
                ? null
                : _idNumberController.text.trim(),
            courseId: _selectedCourseId,
            courseProgram: _selectedCourseProgram,
          );

      context.push('/contact-information');
    }
  }
}
