import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';

/// Department selection page.
/// Allows users to select a department via combobox, then choose to
/// view the live queue or avail services.
class DepartmentSelectionPage extends ConsumerStatefulWidget {
  const DepartmentSelectionPage({super.key});

  @override
  ConsumerState<DepartmentSelectionPage> createState() =>
      _DepartmentSelectionPageState();
}

class _DepartmentSelectionPageState
    extends ConsumerState<DepartmentSelectionPage> {
  String? _selectedDepartment;

  /// Available departments — replace with actual data from API/provider.
  static const List<String> _departments = [
    'Registrar',
    'Library',
    'Office of the Student Affairs',
    'Cashier',
  ];

  @override
  Widget build(BuildContext context) {
    // Load saved department from provider on first build
    final formData = ref.watch(queueFormProvider);
    if (formData.department != null && _selectedDepartment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedDepartment = formData.department;
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
                    'Select a Department',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: EZSpacing.xl),

                  // Department combobox
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    items: _departments.map((department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                        // Save department to provider (clears old services)
                        ref
                            .read(queueFormProvider.notifier)
                            .updateDepartment(department: value);
                      }
                    },
                    hint: const Text('Choose a department'),
                    isExpanded: true,
                  ),

                  // Action buttons (shown after department is selected)
                  if (_selectedDepartment != null) ...[
                    const SizedBox(height: EZSpacing.xxl),

                    // Button 1: View Live Queue
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/department-queue?dept=${Uri.encodeComponent(_selectedDepartment!)}',
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: Text(
                          'View Live Queue',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
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
                      ),
                    ),

                    const SizedBox(height: EZSpacing.md),

                    // Button 2: Avail Services
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/service-selection');
                        },
                        icon: const Icon(Icons.assignment),
                        label: Text(
                          'Avail Services',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
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
}
