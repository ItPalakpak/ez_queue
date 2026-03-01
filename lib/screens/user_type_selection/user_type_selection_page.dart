import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';

/// User type selection page.
/// Allows users to select their type via combobox, select course/program,
/// enter ID number with dynamic placeholder, and specify PWD status.
class UserTypeSelectionPage extends ConsumerStatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  ConsumerState<UserTypeSelectionPage> createState() =>
      _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends ConsumerState<UserTypeSelectionPage> {
  String? _selectedUserType;
  String? _selectedCourseProgram;
  bool _isPWD = false;
  final TextEditingController _pwdSpecificationController =
      TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  /// Available user types.
  static const List<String> _userTypes = [
    'Outsider',
    'Student',
    'Staff',
    'Faculty',
    'Alumni',
  ];

  /// Available course/program abbreviations.
  static const List<String> _coursePrograms = [
    'BSIT',
    'BSSW',
    'BSCE',
    'BSA',
    'BSBA',
    'BSED',
    'BEED',
    'BSCRIM',
  ];

  /// Check if selected user type requires ID number.
  bool get _requiresIdNumber {
    return _selectedUserType != null &&
        ['Student', 'Faculty', 'Staff', 'Alumni'].contains(_selectedUserType);
  }

  /// Check if selected user type requires course/program.
  bool get _requiresCourseProgram {
    return _selectedUserType != null &&
        ['Student', 'Faculty', 'Staff', 'Alumni'].contains(_selectedUserType);
  }

  /// Get dynamic placeholder text for ID number based on user type.
  String get _idNumberHintText {
    return switch (_selectedUserType) {
      'Student' => 'Please enter your student ID of this institution',
      'Faculty' => 'Please enter your faculty ID of this institution',
      'Staff' => 'Please enter your staff ID of this institution',
      'Alumni' => 'Please enter your alumni ID of this institution',
      _ => 'Enter your institution ID number',
    };
  }

  @override
  void dispose() {
    _pwdSpecificationController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load saved data from provider
    final formData = ref.watch(queueFormProvider);
    if (formData.userType != null && _selectedUserType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedUserType = formData.userType;
            _selectedCourseProgram = formData.courseProgram;
            _isPWD = formData.isPWD;
            if (formData.idNumber != null) {
              _idNumberController.text = formData.idNumber!;
            }
            if (formData.pwdSpecification != null) {
              _pwdSpecificationController.text = formData.pwdSpecification!;
            }
          });
        }
      });
    }
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          const TopNavBar(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: EZSpacing.xl),

                  // User type combobox
                  Text(
                    'User Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUserType,
                    decoration: InputDecoration(
                      labelText: 'Select User Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    items: _userTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUserType = value;
                        // Clear ID and course when switching to Outsider
                        if (![
                          'Student',
                          'Faculty',
                          'Staff',
                          'Alumni',
                        ].contains(value)) {
                          _idNumberController.clear();
                          _selectedCourseProgram = null;
                        }
                      });
                    },
                    hint: const Text('Choose your user type'),
                    isExpanded: true,
                  ),

                  // Course/Program combobox (shown for institution-affiliated types)
                  if (_requiresCourseProgram) ...[
                    const SizedBox(height: EZSpacing.xxl),
                    Text(
                      'Course / Program',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCourseProgram,
                      decoration: InputDecoration(
                        labelText: 'Select Course/Program',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      items: _coursePrograms.map((course) {
                        return DropdownMenuItem<String>(
                          value: course,
                          child: Text(course),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCourseProgram = value;
                        });
                      },
                      hint: const Text('Choose your course/program'),
                      isExpanded: true,
                    ),
                  ],

                  // ID Number input (only shown for Student, Faculty, Staff, Alumni)
                  if (_requiresIdNumber) ...[
                    const SizedBox(height: EZSpacing.xxl),
                    Text(
                      'ID Number',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    TextField(
                      controller: _idNumberController,
                      decoration: InputDecoration(
                        hintText: _idNumberHintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                  ],

                  const SizedBox(height: EZSpacing.xxl),

                  // PWD checkbox
                  Card(
                    child: CheckboxListTile(
                      title: const Text('Person with Disability (PWD)'),
                      value: _isPWD,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPWD = value ?? false;
                          if (!_isPWD) {
                            _pwdSpecificationController.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),

                  // PWD specification input (only shown when PWD is checked)
                  if (_isPWD) ...[
                    const SizedBox(height: EZSpacing.lg),
                    Text(
                      'PWD Specification',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    TextField(
                      controller: _pwdSpecificationController,
                      decoration: InputDecoration(
                        hintText: 'Enter your disability specification',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                    ),
                  ],

                  if (_selectedUserType != null) ...[
                    const SizedBox(height: EZSpacing.xxl),
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: EZSpacing.md,
                            horizontal: EZSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              EZSpacing.radiusMd,
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                        ),
                        child: Text(
                          'Continue',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle continue button press.
  void _handleContinue() {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a user type.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_requiresIdNumber && _idNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your institution ID number.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_requiresCourseProgram && _selectedCourseProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your course/program.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_isPWD && _pwdSpecificationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please specify your disability if you selected PWD.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Save user type information to state
    ref
        .read(queueFormProvider.notifier)
        .updateUserType(
          userType: _selectedUserType!,
          idNumber: _idNumberController.text.trim().isEmpty
              ? null
              : _idNumberController.text.trim(),
          courseProgram: _selectedCourseProgram,
          isPWD: _isPWD,
          pwdSpecification: _pwdSpecificationController.text.trim().isEmpty
              ? null
              : _pwdSpecificationController.text.trim(),
        );

    // Navigate to personal information page
    context.push('/personal-information');
  }
}
