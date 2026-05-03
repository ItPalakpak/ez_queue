import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/widgets/ez_form_text_field.dart';

/// Cancel queue page where users can provide a reason for cancellation.
class CancelQueuePage extends ConsumerStatefulWidget {
  const CancelQueuePage({super.key});

  @override
  ConsumerState<CancelQueuePage> createState() => _CancelQueuePageState();
}

class _CancelQueuePageState extends ConsumerState<CancelQueuePage> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(queueTicketProvider);

    if (tickets.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            // Top navigation bar
            const TopNavBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No tickets to cancel.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: EZSpacing.lg),
                    EZButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      'Cancel Queue',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: EZSpacing.xl),

                    // Warning message
                    EZCard(
                      padding: EdgeInsets.zero,
                      child: Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(EZSpacing.lg),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: EZSpacing.md),
                              Expanded(
                                child: Text(
                                  'Are you sure you want to cancel your queue?',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (tickets.isNotEmpty) ...[
                      const SizedBox(height: EZSpacing.lg),
                      // Ticket information
                      EZCard(
                        padding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(EZSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket Information',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: EZSpacing.md),
                              ...tickets.map(
                                (ticket) => Column(
                                  children: [
                                    Text(
                                      'Ticket Number: ${ticket.ticketNumber}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Department: ${ticket.departmentName}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Service: ${ticket.serviceName}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    if (tickets.length > 1 &&
                                        tickets.last != ticket)
                                      const Divider(height: EZSpacing.lg),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: EZSpacing.xl),

                    // Reason input
                    Text(
                      'Reason for Cancellation',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    EZFormTextField(
                      controller: _reasonController,
                      hintText: 'Please provide a reason for cancelling',
                      maxLines: 5,
                      maxLength: 500,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a reason for cancellation';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: EZSpacing.xxl),

                    // Confirm cancellation button
                    SizedBox(
                      width: double.infinity,
                      child: EZButton(
                        onPressed: () => _handleCancelQueue(context, ref),
                        child: Text('Confirm Cancellation'),
                      ),
                    ),

                    const SizedBox(height: EZSpacing.md),

                    // Back button
                    SizedBox(
                      width: double.infinity,
                      child: EZButton(
                        isSecondary: true,
                        onPressed: () => context.pop(),
                        child: Text('Go Back'),
                      ),
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

  /// Handle cancel queue confirmation.
  void _handleCancelQueue(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _reasonController.text.trim();
      final tickets = ref.read(queueTicketProvider);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: Text(
            'Are you sure you want to cancel ${tickets.length == 1 ? "this ticket" : "all ${tickets.length} tickets"}? This action cannot be undone.\n\n'
            'Reason: $reason',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // CHANGED: actual API call to cancel each ticket with reason
                final apiService = ApiService();
                String? errorMessage;

                try {
                  for (final ticket in tickets) {
                    await apiService.cancelTicket(ticket.id, reason);
                  }
                } catch (e) {
                  errorMessage = e.toString().replaceFirst('Exception: ', '');
                }

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop(); // Close the dialog

                if (errorMessage != null) {
                  ref.read(queueTicketProvider.notifier).clearTickets();
                  ref.read(queueFormProvider.notifier).reset();

                  if (context.mounted) {
                    context.go('/');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cancellation failed: $errorMessage'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                  return;
                }

                ref.read(queueTicketProvider.notifier).clearTickets();
                ref.read(queueFormProvider.notifier).reset();

                // Navigate back to landing page
                if (context.mounted) {
                  context.go('/');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Queue cancelled successfully'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
    }
  }
}
