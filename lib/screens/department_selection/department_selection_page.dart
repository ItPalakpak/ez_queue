import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/theme_customizer_button.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:go_router/go_router.dart';

/// Department and service selection page.
/// Allows users to select a department and services they want to avail.
class DepartmentSelectionPage extends ConsumerStatefulWidget {
  const DepartmentSelectionPage({super.key});

  @override
  ConsumerState<DepartmentSelectionPage> createState() =>
      _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState
    extends ConsumerState<DepartmentSelectionPage> {
  String? _selectedDepartment;
  final Set<String> _selectedServices = <String>{};

  // Sample data - replace with actual data from API/provider
  final List<String> _departments = [
    'Registrar',
    'Library',
    'Office of the Student Affairs',
    'Cashier',
  ];

  final Map<String, List<String>> _departmentServices = {
    'Registrar': [
      'General Inquiry',
      'Complaint Resolution',
      'Account Assistance',
      'Student Information',
    ],
    'Library': ['Book Request', 'Book Return', 'Book Renewal'],
    'Office of the Student Affairs': [
      'Student Complaint',
      'Student Request',
      'Student Information',
    ],
    'Cashier': ['Payment', 'Payment Inquiry', 'Payment Refund'],
  };

  List<String> get _availableServices {
    if (_selectedDepartment == null) {
      return [];
    }
    return _departmentServices[_selectedDepartment] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Load saved data from provider
    final formData = ref.watch(queueFormProvider);
    if (formData.department != null && _selectedDepartment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedDepartment = formData.department;
            _selectedServices.addAll(formData.services);
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
                        

                        // Department selection
                        Text(
                          'Select a Department',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: EZSpacing.md),
                        _buildDepartmentSelector(),

                        if (_selectedDepartment != null) ...[
                          const SizedBox(height: EZSpacing.xxl),
                          // Service selection
                          Text(
                            'Select the Service/s you want to avail',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.md),
                          _buildServiceSelector(),
                        ],

                        if (_selectedDepartment != null &&
                            _selectedServices.isNotEmpty) ...[
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

  /// Build department selector widget.
  Widget _buildDepartmentSelector() {
    return Column(
      children: _departments.map((department) {
        final isSelected = _selectedDepartment == department;
        return Card(
          margin: const EdgeInsets.only(bottom: EZSpacing.sm),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : null,
          child: ListTile(
            title: Text(department),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : null,
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedDepartment = department;
                _selectedServices
                    .clear(); // Clear services when department changes
              });
            },
          ),
        );
      }).toList(),
    );
  }

  /// Build service selector widget.
  Widget _buildServiceSelector() {
    if (_availableServices.isEmpty) {
      return Text(
        'No services available for this department.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      children: _availableServices.map((service) {
        final isSelected = _selectedServices.contains(service);
        return Card(
          margin: const EdgeInsets.only(bottom: EZSpacing.sm),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : null,
          child: CheckboxListTile(
            title: Text(service),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedServices.add(service);
                } else {
                  _selectedServices.remove(service);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      }).toList(),
    );
  }

  /// Handle continue button press.
  void _handleContinue() {
    if (_selectedDepartment == null || _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select a department and at least one service.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Save department and services to state
    ref
        .read(queueFormProvider.notifier)
        .updateDepartmentAndServices(
          department: _selectedDepartment!,
          services: _selectedServices.toList(),
        );

    // Navigate to user type selection page
    context.push('/user-type-selection');
  }
}
