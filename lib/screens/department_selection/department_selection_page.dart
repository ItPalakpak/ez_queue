import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/models/api_models.dart';
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
  ApiDepartment? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(apiDepartmentsProvider);
    });
  }

  void _selectDepartment(ApiDepartment department) {
    setState(() {
      _selectedDepartment = department;
    });
    // Save department to provider (clears old services)
    ref
        .read(queueFormProvider.notifier)
        .updateDepartment(
          departmentId: department.id,
          department: department.name,
        );
    // Auto-redirect to service selection page
    context.push('/service-selection');
  }

  @override
  Widget build(BuildContext context) {
    // Load saved department from provider on first build
    final formData = ref.watch(queueFormProvider);
    if (formData.department != null && _selectedDepartment == null) {
      // NOTE: We rely on the initial API load instead of hardcoded lists.
      // Auto-reselection could be implemented here logic if the full object is cached,
      // but for this task, user will just select the dynamic list.
    }

    final departmentsAsync = ref.watch(apiDepartmentsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          const TopNavBar(),

          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(apiDepartmentsProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(EZSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step header - icon and text in one row
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
                            child: Center(
                              child: Icon(
                                Icons.business_rounded,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: EZSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Department',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: EZSpacing.xs),
                                Text(
                                  'Choose where you want to queue',
                                  style: Theme.of(context).textTheme.bodyLarge
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
                        ],
                      ),
                    ),

                    // Department selection using card-style radio buttons
                    Text(
                      'Available Departments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    departmentsAsync.when(
                      data: (departments) {
                        if (departments.isEmpty) {
                          return const Center(
                            child: Text('No departments available'),
                          );
                        }
                        // CHANGED: Sort departments alphabetically by name
                        final sortedDepartments = List<ApiDepartment>.from(departments)
                          ..sort((a, b) => a.name.compareTo(b.name));
                        return RadioGroup<ApiDepartment>(
                          groupValue: _selectedDepartment,
                          onChanged: (ApiDepartment? value) {
                            if (value != null) {
                              _selectDepartment(value);
                            }
                          },
                          child: Column(
                            children: sortedDepartments.map((department) {
                              final isDisabled = formData.disabledDepartments
                                  .contains(department.id);
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: EZSpacing.md,
                                ),
                                child: EZCard(
                                  padding: EdgeInsets.zero,
                                  child: RadioListTile<ApiDepartment>(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            department.name,
                                            style: TextStyle(
                                              color: isDisabled || !department.isQueueOpen
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.5)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (isDisabled)
                                          Tooltip(
                                            message:
                                                'You already have an active queue in this department',
                                            child: Icon(
                                              Icons.block,
                                              size: 16,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        if (!isDisabled && !department.isQueueOpen)
                                          Icon(
                                            Icons.lock_outline,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (department.description != null)
                                          Text(
                                            department.description!,
                                            style: TextStyle(
                                              color: isDisabled || !department.isQueueOpen
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.4)
                                                  : null,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        if (!department.isQueueOpen)
                                          Text(
                                            department.queueClosedReason ?? 'Queue is currently closed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        else
                                          Text(
                                            '${department.currentWaiting > 0 ? '${department.currentWaiting} in queue' : 'No queue'}'
                                            '${department.dailyTicketLimit > 0 ? ' · ${department.dailyTicketsUsed}/${department.dailyTicketLimit} tickets today' : ''}'
                                            '${department.queueCutoffTime != null ? ' · Closes at ${department.queueCutoffTime!.substring(0, 5)}' : ''}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                      ],
                                    ),
                                    value: department,
                                    enabled: !isDisabled && department.isQueueOpen,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) =>
                          Center(child: Text('Failed to load departments: $e')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
