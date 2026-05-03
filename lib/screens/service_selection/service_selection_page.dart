import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/models/api_models.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/utils/format_utils.dart';

/// Service selection page.
/// Allows users to select services for their queue request.
/// Purpose and items are collected on the subsequent Details page.
class ServiceSelectionPage extends ConsumerStatefulWidget {
  const ServiceSelectionPage({super.key});

  @override
  ConsumerState<ServiceSelectionPage> createState() =>
      _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends ConsumerState<ServiceSelectionPage> {
  final Set<int> _selectedServiceIds = <int>{};
  final Map<int, String> _serviceNames = {};

  @override
  void initState() {
    super.initState();
    // CHANGED: no need to invalidate — StreamProvider auto-polls every 5 s
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(queueFormProvider);
    final department = formData.department;
    final departmentId = formData.departmentId;
    if (departmentId == null) {
      return const Scaffold(
        body: Center(child: Text('Please select a department first.')),
      );
    }

    final servicesAsync = ref.watch(apiServicesProvider(departmentId));
    // CHANGED: allowMultiple now comes from the services API response directly
    final allowMultiple = servicesAsync.value?.allowMultipleServices ?? false;

    // Load saved data on first build
    if (formData.serviceIds.isNotEmpty && _selectedServiceIds.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedServiceIds.addAll(formData.serviceIds);
            for (var i = 0; i < formData.serviceIds.length; i++) {
              if (i < formData.services.length) {
                _serviceNames[formData.serviceIds[i]] = formData.services[i];
              }
            }
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
                          child: const Center(
                            child: Text('📋', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(width: EZSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Services',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              if (department != null) ...[
                                const SizedBox(height: EZSpacing.xs),
                                Text(
                                  'Department: $department',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Service selection
                  Text(
                    'Select the Service you want to avail',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (allowMultiple)
                    Padding(
                      padding: const EdgeInsets.only(top: EZSpacing.xs),
                      child: Text(
                        '(You may select multiple services)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: EZSpacing.md),
                  servicesAsync.when(
                    data: (response) =>
                        _buildServiceSelector(response.services, allowMultiple),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load services:\n$e',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_selectedServiceIds.isNotEmpty) ...[
                    const SizedBox(height: EZSpacing.xxl),
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: EZButton(
                        onPressed: _handleContinue,
                        child: Text('Continue'),
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

  /// Build service checkboxes.
  Widget _buildServiceSelector(
    List<ApiQueueService> availableServices,
    bool allowMultiple,
  ) {
    if (availableServices.isEmpty) {
      return Text(
        'No services available for this department.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      children: availableServices.map((service) {
        final isSelected = _selectedServiceIds.contains(service.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: EZSpacing.md),
          child: EZCard(
            padding: EdgeInsets.zero,
            child: allowMultiple
                ? CheckboxListTile(
                    title: Text(service.name),
                    subtitle: service.description != null
                        ? Text(service.description!)
                        : null,
                    secondary: Text(
                      formatDuration(service.estimatedMinutes, compact: true),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedServiceIds.add(service.id);
                          _serviceNames[service.id] = service.name;
                        } else {
                          _selectedServiceIds.remove(service.id);
                          _serviceNames.remove(service.id);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  )
                : ListTile(
                    title: Text(service.name),
                    subtitle: service.description != null
                        ? Text(service.description!)
                        : null,
                    trailing: Text(
                      formatDuration(service.estimatedMinutes, compact: true),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    leading: Radio<int>(
                      value: service.id,
                      groupValue: _selectedServiceIds.isNotEmpty
                          ? _selectedServiceIds.first
                          : null,
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _selectedServiceIds.clear();
                            _serviceNames.clear();
                            _selectedServiceIds.add(service.id);
                            _serviceNames[service.id] = service.name;
                          });
                        }
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedServiceIds.clear();
                        _serviceNames.clear();
                        _selectedServiceIds.add(service.id);
                        _serviceNames[service.id] = service.name;
                      });
                    },
                  ),
          ),
        );
      }).toList(),
    );
  }

  /// Handle continue button press.
  void _handleContinue() {
    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one service.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Prepare lists
    final selectedIds = _selectedServiceIds.toList();
    final selectedNames = selectedIds
        .map((id) => _serviceNames[id] ?? 'Unknown Service')
        .toList();

    // Save service selection to state (purpose and items will be set on Details page)
    ref
        .read(queueFormProvider.notifier)
        .updateServiceInfo(serviceIds: selectedIds, services: selectedNames);

    // Navigate to details information page
    context.push('/details-information');
  }
}
