import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/theme_customizer_button.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:go_router/go_router.dart';

/// User type selection page.
/// Allows users to select if they are outsiders or students,
/// and specify if they are PWDs with optional specification.
class UserTypeSelectionPage extends ConsumerStatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  ConsumerState<UserTypeSelectionPage> createState() =>
      _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends ConsumerState<UserTypeSelectionPage> {
  String? _selectedUserType;
  bool _isPWD = false;
  final TextEditingController _pwdSpecificationController =
      TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  /// Check if selected user type requires ID number.
  bool get _requiresIdNumber {
    return _selectedUserType != null &&
        ['Student', 'Faculty', 'Staff', 'Alumni'].contains(_selectedUserType);
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top section with logo at top left
                Padding(
                  padding: const EdgeInsets.only(
                    left: EZSpacing.lg,
                    top: EZSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: const AppLogo(height: 60, width: 60),
                  ),
                ),

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

                        // User type selection
                        Text(
                          'User Type',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: EZSpacing.md),
                        _buildUserTypeSelector(),

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
                              hintText: 'Enter your institution ID number',
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
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              child: Text(
                                'Continue',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
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
          ),
          // Theme customizer button at top right
          const ThemeCustomizerButton(),
        ],
      ),
    );
  }

  /// Build user type selector widget.
  Widget _buildUserTypeSelector() {
    return Column(
      children: [
        _buildUserTypeOption('Outsider', 'I am an outsider'),
        const SizedBox(height: EZSpacing.sm),
        _buildUserTypeOption('Student', 'I am a student of this institution'),
        const SizedBox(height: EZSpacing.sm),
        _buildUserTypeOption('Staff', 'I am a staff of this institution'),
        const SizedBox(height: EZSpacing.sm),
        _buildUserTypeOption('Faculty', 'I am a faculty of this institution'),
        const SizedBox(height: EZSpacing.sm),
        _buildUserTypeOption('Alumni', 'I am an alumni of this institution'),
      ],
    );
  }

  /// Build individual user type option.
  Widget _buildUserTypeOption(String type, String label) {
    final isSelected = _selectedUserType == type;
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        title: Text(label),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.secondary,
              )
            : null,
        selected: isSelected,
        onTap: () {
          setState(() {
            _selectedUserType = type;
            // Clear ID number if user type changes to one that doesn't require it
            if (!['Student', 'Faculty', 'Staff', 'Alumni'].contains(type)) {
              _idNumberController.clear();
            }
          });
        },
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
          isPWD: _isPWD,
          pwdSpecification: _pwdSpecificationController.text.trim().isEmpty
              ? null
              : _pwdSpecificationController.text.trim(),
        );

    // Navigate to personal information page
    context.push('/personal-information');
  }
}
