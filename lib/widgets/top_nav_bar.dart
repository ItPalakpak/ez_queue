import 'package:flutter/material.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:ez_queue/services/device_token_manager.dart';
import 'package:go_router/go_router.dart';

/// Reusable top navigation bar widget used across all pages.
///
/// Contains:
/// - Optional back button (left side)
/// - App logo (center-left)
/// - Home button (top-right, beside theme customizer) — optional
/// - Theme customizer button (top-right corner)
class TopNavBar extends StatelessWidget {
  /// Whether to show the back button. Defaults to true.
  final bool showBackButton;

  /// Whether to show the home button. Defaults to true.
  final bool showHomeButton;

  /// Whether to show the warning/notice button. Defaults to true.
  final bool showWarningButton;

  /// Custom back action. If null, defaults to `context.pop()`.
  final VoidCallback? onBack;

  const TopNavBar({
    super.key,
    this.showBackButton = true,
    this.showHomeButton = true,
    this.showWarningButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left side: back button + logo
        Padding(
          padding: const EdgeInsets.only(left: EZSpacing.sm, top: EZSpacing.sm),
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onBack ?? () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Go Back',
                  ),
                const AppLogo(height: 60, width: 60),
              ],
            ),
          ),
        ),
        // Right side: home button + active tickets + warning + theme customizer
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: EZSpacing.sm,
                right: EZSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showWarningButton) const _WarningButton(),
                  if (showHomeButton)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => context.go('/'),
                      icon: Icon(
                        Icons.home,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Go to Home',
                    ),
                  const _ActiveTicketsButton(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context.push('/theme-customizer'),
                    icon: Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Theme Customizer',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveTicketsButton extends StatefulWidget {
  const _ActiveTicketsButton();

  @override
  State<_ActiveTicketsButton> createState() => _ActiveTicketsButtonState();
}

class _ActiveTicketsButtonState extends State<_ActiveTicketsButton> {
  void _showTicketsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: EZSpacing.sm),
              const Text('My Active Tickets'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<String>(
              future: DeviceTokenManager.getDeviceToken(),
              builder: (context, tokenSnapshot) {
                if (tokenSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!tokenSnapshot.hasData || tokenSnapshot.data!.isEmpty) {
                  return const Center(child: Text('Device token not found.'));
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: apiService.getActiveTicketsByDeviceToken(tokenSnapshot.data!),
                  builder: (context, ticketsSnapshot) {
                    if (ticketsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (ticketsSnapshot.hasError) {
                      return Center(child: Text('Error: ${ticketsSnapshot.error}'));
                    }

                    final tickets = ticketsSnapshot.data ?? [];
                    if (tickets.isEmpty) {
                      return const Center(child: Text('No active tickets found.'));
                    }

                    return ListView.separated(
                      itemCount: tickets.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return ListTile(
                          title: Text(
                            ticket['ticket_number'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(ticket['department_name'] ?? 'Department'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).pop(); // Close dialog
                            context.push(
                              '/queue-display?ticketNumber=${ticket['ticket_number']}&departmentId=${ticket['department_id']}&departmentName=${ticket['department_name']}'
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: _showTicketsDialog,
      icon: Icon(
        Icons.receipt_long,
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'My Active Tickets',
    );
  }
}

class _WarningButton extends StatelessWidget {
  const _WarningButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () {
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
              '• You cannot create another queue in a department where you have an active queue\n\n'
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
    );
  }
}
