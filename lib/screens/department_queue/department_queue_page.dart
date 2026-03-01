import 'package:flutter/material.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';

/// Department-specific queue display page (read-only).
/// Shows the live queue status for a specific department.
class DepartmentQueuePage extends StatelessWidget {
  /// The department name to display queue for.
  final String department;

  const DepartmentQueuePage({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    // Sample queue data per department — replace with actual API data.
    final Map<String, _DepartmentQueueData> sampleData = {
      'Registrar': _DepartmentQueueData(
        currentServing: 8,
        nextNumbers: [9, 10, 11, 12, 13],
        window: 'Window 1',
      ),
      'Library': _DepartmentQueueData(
        currentServing: 3,
        nextNumbers: [4, 5, 6],
        window: 'Counter A',
      ),
      'Office of the Student Affairs': _DepartmentQueueData(
        currentServing: 15,
        nextNumbers: [16, 17, 18, 19],
        window: 'Window 2',
      ),
      'Cashier': _DepartmentQueueData(
        currentServing: 22,
        nextNumbers: [23, 24, 25, 26, 27],
        window: 'Window 3',
      ),
    };

    final queueData =
        sampleData[department] ??
        _DepartmentQueueData(currentServing: 0, nextNumbers: [], window: 'N/A');

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
                  // Page title with department
                  Text(
                    '$department Queue Status',
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
                      queueData.window,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: EZSpacing.xl),

                  // Currently serving card
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
                              '${queueData.currentServing}',
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
                  if (queueData.nextNumbers.isEmpty)
                    Text(
                      'No upcoming queue numbers.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    )
                  else
                    Wrap(
                      spacing: EZSpacing.sm,
                      runSpacing: EZSpacing.sm,
                      children: queueData.nextNumbers.map((number) {
                        return Chip(
                          label: Text('$number'),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: EZSpacing.xxl),

                  // Info message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(EZSpacing.lg),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: EZSpacing.md),
                          Expanded(
                            child: Text(
                              'This is the live queue status for $department. '
                              'Go back to avail services and join the queue.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
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
}

/// Internal data class for sample department queue data.
class _DepartmentQueueData {
  final int currentServing;
  final List<int> nextNumbers;
  final String window;

  const _DepartmentQueueData({
    required this.currentServing,
    required this.nextNumbers,
    required this.window,
  });
}
