import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';

/// Queue display page showing current queue status.
class QueueDisplayPage extends ConsumerWidget {
  const QueueDisplayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticket = ref.watch(queueTicketProvider);

    // Sample queue data - replace with actual data from API
    final currentNumber = 12;
    final nextNumbers = [13, 14, 15, 16, 17];
    final estimatedWait = ticket?.estimatedWaitMinutes ?? 0;

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          Stack(
            children: [
              const TopNavBar(),
              // Warning button positioned to the left of home button
              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: EZSpacing.sm,
                      right:
                          100, // Position to the left of home and theme buttons
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Show reminder dialog on tap
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: EZSpacing.sm),
                                const Text('Important Reminders'),
                              ],
                            ),
                            content: const Text(
                              '• Always maintain an internet connection\n\n'
                              '• Wait for notifications via email and this app for queue status updates',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.warning_amber_rounded),
                      color: Colors.orange,
                      tooltip: 'Important Reminders',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title with department
                  Text(
                    ticket != null
                        ? '${ticket.department} Queue Status'
                        : 'Queue Status',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  // Window/Section display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EZSpacing.md,
                      vertical: EZSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
                    ),
                    child: Text(
                      'Window 1',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: EZSpacing.xl),

                  // Current number being served
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(EZSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currently Serving',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: EZSpacing.md),
                          Center(
                            child: Text(
                              '$currentNumber',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: EZSpacing.lg),

                  // Next numbers
                  Text(
                    'Next Numbers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  Wrap(
                    spacing: EZSpacing.sm,
                    runSpacing: EZSpacing.sm,
                    children: nextNumbers.map((number) {
                      return Chip(
                        label: Text('$number'),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      );
                    }).toList(),
                  ),

                  if (ticket != null) ...[
                    const SizedBox(height: EZSpacing.xxl),

                    // User's number (highlighted)
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(EZSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Number',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: EZSpacing.md),
                            Center(
                              child: Text(
                                '${ticket.queuePosition}',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(height: EZSpacing.md),
                            Center(
                              child: Text(
                                'Ticket: ${ticket.ticketNumber}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: EZSpacing.lg),

                    // Estimated wait time
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(EZSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Wait Time',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: EZSpacing.xs),
                                Text(
                                  'Approximately $estimatedWait minutes',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            Icon(
                              Icons.access_time,
                              size: 40,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: EZSpacing.xxl),

                    // Cancel queue button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/cancel-queue');
                        },
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
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Text(
                          'Cancel Queue',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.error,
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
    );
  }
}
