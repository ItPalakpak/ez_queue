import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/models/queue_ticket.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/services/device_token_manager.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:go_router/go_router.dart';

/// Confirmation page where users can review and edit their details.
class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  /// Returns the section header title for the department block.
  /// Uses singular or plural form based on the number of selected services.
  String _buildDepartmentSectionTitle(int serviceCount) {
    final serviceWord = serviceCount == 1 ? 'Service' : 'Services';
    return 'Department Selected and $serviceWord Availed';
  }

  /// Returns the inline label for the services row.
  /// Uses singular or plural form based on the number of selected services.
  String _buildServiceLabel(int serviceCount) {
    return serviceCount == 1 ? 'Service Availed' : 'Services Availed';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(queueFormProvider);
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
                            child: Text('👁️', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(width: EZSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review Your Details',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: EZSpacing.xs),
                              Text(
                                'Verify your information before generating ticket',
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

                  // Department & Services section
                  _buildInfoSection(
                    context,
                    _buildDepartmentSectionTitle(formData.services.length),
                    [
                      'Department: ${formData.department ?? 'Not selected'}',
                      '${_buildServiceLabel(formData.services.length)}: ${formData.services.isEmpty ? 'None' : formData.services.join(', ')}',
                    ],
                    '/service-selection',
                  ),

                  const SizedBox(height: EZSpacing.lg),

                  // Additional Details section
                  _buildInfoSection(context, 'Additional Details', [
                    if (formData.purpose != null)
                      'Purpose: ${formData.purpose}'
                    else
                      'Purpose: Not specified',
                    if (formData.items.isNotEmpty)
                      'Items: ${formData.items.map((item) => '${item.name} x${item.quantity}').join(', ')}'
                    else
                      'Items: None',
                  ], '/details-information'),

                  const SizedBox(height: EZSpacing.lg),

                  // User Information (Identity)
                  _buildInfoSection(context, 'Identity Information', [
                    'User Type: ${formData.userType ?? 'Not selected'}',
                    'Full Name: ${formData.fullName ?? 'Not provided'}',
                    if (formData.courseProgram != null)
                      'Course/Program: ${formData.courseProgram}',
                    if (formData.idNumber != null)
                      'ID Number: ${formData.idNumber}',
                  ], '/identity-information'),

                  const SizedBox(height: EZSpacing.lg),

                  // Contact Information
                  _buildInfoSection(context, 'Contact Information', [
                    'Email: ${formData.email ?? 'Not provided'}',
                    'Contact Number: ${formData.contactNumber ?? 'Not provided'}',
                    if (formData.priorityWeight > 1) 'Priority: Priority Queue',
                    if (formData.priorityWeight > 1 && formData.priorityIdNumber != null)
                      'Priority ID: ${formData.priorityIdNumber}',
                  ], '/contact-information'),

                  const SizedBox(height: EZSpacing.xxl),

                  // Generate Ticket button
                  SizedBox(
                    width: double.infinity,
                    child: EZButton(
                      onPressed: formData.isComplete
                          ? () => _handleGenerateTicket(context, ref, formData)
                          : null,
                      child: Text('Generate Ticket'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build information section with edit button.
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<String> details,
    String editRoute,
  ) {
    return EZCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(EZSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(editRoute),
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: EZSpacing.md),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: EZSpacing.xs),
                child: Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle generate ticket button press.
  Future<void> _handleGenerateTicket(
    BuildContext context,
    WidgetRef ref,
    dynamic formData,
  ) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String deviceToken = await DeviceTokenManager.getDeviceToken();


      List<QueueTicket> generatedTickets = [];

      for (int serviceId in formData.serviceIds) {
        String? mappedUserType = formData.userType?.toLowerCase();
        if (mappedUserType == 'faculty/staff') {
          mappedUserType = 'faculty';
        }

        final payload = {
          'department_id': formData.departmentId,
          'service_id': serviceId,
          'student_name': formData.fullName,
          'user_type': mappedUserType,
          if (formData.idNumber != null) 'student_id': formData.idNumber,
          if (formData.idNumber != null) 'employee_id': formData.idNumber,
          if (formData.contactNumber != null) 'phone': formData.contactNumber,
          if (formData.email != null) 'email': formData.email,
          if (formData.courseId != null) 'course_id': formData.courseId,
          if (formData.purpose != null) 'purpose': formData.purpose,
          'priority_weight': formData.priorityWeight,
          'is_priority': formData.priorityWeight > 1,
          if (formData.priorityIdNumber != null)
            'priority_id_number': formData.priorityIdNumber,
          'device_token': deviceToken,
        };

        final ticket = await apiService.createTicket(payload);
        generatedTickets.add(ticket);
      }

      // Hide loading overlay
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Save tickets to provider
      ref.read(queueTicketProvider.notifier).setTickets(generatedTickets);

      // Navigate to ticket preview page
      if (context.mounted) {
        context.push('/ticket-preview');
      }
    } catch (e) {
      // Hide loading overlay
      if (context.mounted) {
        Navigator.of(context).pop();
        // CHANGED: Show only user-friendly error message without technical details
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
