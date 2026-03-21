import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
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

  void _selectDepartment(String department) {
    setState(() {
      _selectedDepartment = department;
    });
    // Save department to provider (clears old services)
    ref
        .read(queueFormProvider.notifier)
        .updateDepartment(department: department);
    // Auto-redirect to service selection page
    context.push('/service-selection');
  }

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

                  // Department selection using card-style checkboxes
                  Text(
                    'Select a Department',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  ..._departments.map((department) {
                    final isSelected = _selectedDepartment == department;
                    return Card(
                      margin: const EdgeInsets.only(bottom: EZSpacing.sm),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1)
                          : null,
                      child: CheckboxListTile(
                        title: Text(department),
                        value: isSelected,
                        onChanged: (bool? value) {
                          if (value == true) {
                            _selectDepartment(department);
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
