import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/models/queue_ticket.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/theme_customizer_button.dart';
import 'package:ez_queue/widgets/app_logo.dart';
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
                          'Review Your Details',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: EZSpacing.xl),

                        // Department & Services
                        _buildInfoSection(
                          context,
                          _buildDepartmentSectionTitle(
                            formData.services.length,
                          ),
                          [
                            'Department: ${formData.department ?? 'Not selected'}',
                            '${_buildServiceLabel(formData.services.length)}: ${formData.services.isEmpty ? 'None' : formData.services.join(', ')}',
                          ],
                          '/department-selection',
                        ),

                        const SizedBox(height: EZSpacing.lg),

                        // User Information
                        _buildInfoSection(context, 'User Information', [
                          'User Type: ${formData.userType ?? 'Not selected'}',
                          if (formData.idNumber != null)
                            'ID Number: ${formData.idNumber}',
                          if (formData.isPWD) 'PWD: Yes',
                          if (formData.isPWD &&
                              formData.pwdSpecification != null)
                            'PWD Specification: ${formData.pwdSpecification}',
                        ], '/user-type-selection'),

                        const SizedBox(height: EZSpacing.lg),

                        // Personal Information
                        _buildInfoSection(context, 'Personal Information', [
                          'Full Name: ${formData.fullName ?? 'Not provided'}',
                          'Email: ${formData.email ?? 'Not provided'}',
                        ], '/personal-information'),

                        const SizedBox(height: EZSpacing.xxl),

                        // Generate Ticket button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: formData.isComplete
                                ? () => _handleGenerateTicket(
                                    context,
                                    ref,
                                    formData,
                                  )
                                : null,
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
                              'Generate Ticket',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ),
                        ),
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

  /// Build information section with edit button.
  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<String> details,
    String editRoute,
  ) {
    return Card(
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
    // Generate ticket number (sample - replace with actual generation logic)
    final ticketNumber =
        'Q${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Calculate queue position (sample - replace with actual calculation)
    final queuePosition = 5; // Sample position
    final estimatedWaitMinutes = queuePosition * 3; // Sample calculation

    // Create queue ticket
    final ticket = QueueTicket(
      ticketNumber: ticketNumber,
      department: formData.department!,
      services: formData.services,
      userType: formData.userType!,
      idNumber: formData.idNumber,
      fullName: formData.fullName!,
      email: formData.email!,
      isPWD: formData.isPWD,
      pwdSpecification: formData.pwdSpecification,
      createdAt: DateTime.now(),
      queuePosition: queuePosition,
      estimatedWaitMinutes: estimatedWaitMinutes,
    );

    // Save ticket to provider
    ref.read(queueTicketProvider.notifier).setTicket(ticket);

    // Navigate to ticket preview page
    if (context.mounted) {
      context.push('/ticket-preview');
    }
  }
}
