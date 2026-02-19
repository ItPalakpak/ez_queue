import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/theme_customizer_button.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:go_router/go_router.dart';

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
    final ticket = ref.watch(queueTicketProvider);

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
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.1),
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

                          if (ticket != null) ...[
                            const SizedBox(height: EZSpacing.lg),
                            // Ticket information
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(EZSpacing.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ticket Information',
                                      style:
                                          Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: EZSpacing.md),
                                    Text(
                                      'Ticket Number: ${ticket.ticketNumber}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Department: ${ticket.department}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Position: ${ticket.queuePosition}',
                                      style: Theme.of(context).textTheme.bodyLarge,
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
                          TextFormField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              hintText: 'Please provide a reason for cancelling',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  EZSpacing.radiusMd,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            maxLines: 5,
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
                            child: ElevatedButton(
                              onPressed: () => _handleCancelQueue(context, ref),
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Confirm Cancellation',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),

                          const SizedBox(height: EZSpacing.md),

                          // Back button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
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
                              ),
                              child: Text(
                                'Go Back',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  /// Handle cancel queue confirmation.
  void _handleCancelQueue(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _reasonController.text.trim();

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: Text(
            'Are you sure you want to cancel your queue?\n\n'
            'Reason: $reason',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Clear ticket from provider
                ref.read(queueTicketProvider.notifier).clearTicket();
                
                // Clear form data
                ref.read(queueFormProvider.notifier).reset();

                Navigator.of(context).pop();
                
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

