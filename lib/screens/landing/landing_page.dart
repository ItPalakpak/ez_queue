import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// CHANGED: import apiSettingsProvider to gate the Get A Ticket button
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/services/api_service.dart';
// CHANGED: import device token manager to link the tracked ticket to this device
import 'package:ez_queue/services/device_token_manager.dart';
import 'package:ez_queue/utils/theme_helpers.dart';

/// Landing page with EZQueue force that adapts to theme mode.
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    final settingsAsync = ref.watch(apiSettingsProvider);
    // CHANGED: Debug logging to trace settings resolution
    debugPrint('[LandingPage] settingsAsync: $settingsAsync');
    final remoteQueuingEnabled = settingsAsync.maybeWhen(
      data: (s) {
        debugPrint(
          '[LandingPage] remoteQueuingEnabled=${s.remoteQueuingEnabled}, systemStatus=${s.systemStatus}',
        );
        return s.remoteQueuingEnabled;
      },
      orElse: () {
        debugPrint('[LandingPage] settingsAsync orElse — no data yet');
        return false;
      },
    );

    final systemStatus = settingsAsync.maybeWhen(
      data: (s) => s.systemStatus,
      orElse: () => 'active',
    );
    final systemMessage = settingsAsync.maybeWhen(
      data: (s) => s.systemStatusMessage,
      orElse: () => 'The system is unavailable.',
    );
    final systemTimestamp = settingsAsync.maybeWhen(
      data: (s) => s.systemStatusTimestamp,
      orElse: () => null,
    );
    final isSystemOffline = systemStatus != 'active';
    debugPrint(
      '[LandingPage] remoteQueuingEnabled=$remoteQueuingEnabled, isSystemOffline=$isSystemOffline',
    );

    // Select appropriate logo based on theme mode
    final logoPath = isDark
        ? 'assets/photos/logo_for_dark_mode_no_bg.png'
        : 'assets/photos/logo_for_light_mode_no_bg.png';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Warning button positioned to the left of home button
                Align(
                  alignment: Alignment.topRight,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: EZSpacing.sm,
                        right: 44, // Positioned like home button in other pages
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              // Show reminder dialog on tap
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(EZSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Image.asset(
                            logoPath,
                            height:
                                120, // Reduced from 200 for a more compact height
                            width: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image fails to load
                              return Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    EZSpacing.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  Icons.queue,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: EZSpacing.lg),

                          // Subtitle
                          Text(
                            'Digital Queue Monitoring for Clients',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: EZSpacing.xl),

                          // CHANGED: Render blocked state if system offline
                          if (isSystemOffline) ...[
                            Container(
                              padding: const EdgeInsets.all(EZSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                  EZSpacing.md,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.block,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: EZSpacing.md),
                                  Text(
                                    systemStatus == 'maintenance'
                                        ? 'System Maintenance'
                                        : 'System Closed',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: EZSpacing.sm),
                                  Text(
                                    systemMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                  if (systemTimestamp != null) ...[
                                    const SizedBox(height: EZSpacing.md),
                                    Text(
                                      'Expected Resume Time:\n$systemTimestamp',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ] else ...[
                            // Active system rendering
                            if (remoteQueuingEnabled) ...[
                              SizedBox(
                                width: double.infinity,
                                child: EZButton(
                                  onPressed: () {
                                    context.push('/user-type-selection');
                                  },
                                  child: const Text('Get A Ticket'),
                                ),
                              ),
                              // CHANGED: show rate limit info so users know the queueing frequency limit
                              Padding(
                                padding: const EdgeInsets.only(top: EZSpacing.xs),
                                child: settingsAsync.maybeWhen(
                                  data: (s) => Text(
                                    'Limited to ${s.remoteRateLimitMax} ticket${s.remoteRateLimitMax == 1 ? '' : 's'} per ${s.remoteRateLimitDecayMinutes} min per device',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  orElse: () => const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(height: EZSpacing.sm),
                            ],

                            // View Queue Button
                            SizedBox(
                              width: double.infinity,
                              child: EZButton(
                                isSecondary: true,
                                onPressed: () {
                                  context.push('/department-queue');
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.visibility),
                                    const SizedBox(width: EZSpacing.sm),
                                    const Text('View Live Queue'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: EZSpacing.xl),

                            // Quick Track Options
                            const Divider(),
                            const SizedBox(height: EZSpacing.lg),
                            Text(
                              'Track an Existing Ticket',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(height: EZSpacing.xs),
                            Text(
                              'Enter the tracking code from your ticket',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: EZSpacing.sm),
                            _TrackTicketForm(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Top navigation bar — no back button on landing page
          const TopNavBar(showBackButton: false, showHomeButton: false),
        ],
      ),
    );
  }
}

class _TrackTicketForm extends StatefulWidget {
  @override
  State<_TrackTicketForm> createState() => _TrackTicketFormState();
}

class _TrackTicketFormState extends State<_TrackTicketForm> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _currentLength = _controller.text.length);
    });
  }

  /// Show QR scanner dialog for ticket tracking.
  void _showQRScanner() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(EZSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan Ticket QR Code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Scanner
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        Navigator.of(context).pop();
                        String rawValue = barcode.rawValue!.trim();
                        // CHANGED: Parse tracking token from QR data
                        String trackingToken = '';
                        // Look for 'Tracking: XXXXXXXX' line in multi-line QR data
                        for (final line in rawValue.split('\n')) {
                          final trimmed = line.trim();
                          if (trimmed.toUpperCase().startsWith('TRACKING:')) {
                            trackingToken = trimmed
                                .substring('TRACKING:'.length)
                                .trim()
                                .toUpperCase();
                            break;
                          }
                        }
                        // Fallback: if QR is just an 8-char token string
                        if (trackingToken.isEmpty && RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(rawValue.toUpperCase())) {
                          trackingToken = rawValue.toUpperCase();
                        }
                        if (trackingToken.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('No tracking code found in QR code.'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _controller.text = trackingToken;
                        });
                        // Auto-trigger track after short delay
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted && _controller.text.isNotEmpty) {
                            _handleTrack();
                          }
                        });
                        return;
                      }
                    }
                  },
                ),
              ),
              // Instructions
              Padding(
                padding: const EdgeInsets.all(EZSpacing.md),
                child: Text(
                  'Point camera at a ticket QR code',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTrack() async {
    final trackingToken = _controller.text.trim().toUpperCase();
    if (trackingToken.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // CHANGED: Look up by tracking_token and link device for push notifications
      String deviceToken = await DeviceTokenManager.getDeviceToken();
      final ticketData = await apiService.findTicketByToken(
        trackingToken,
        deviceToken: deviceToken,
      );

      if (!mounted) return;

      // Successfully grabbed the active ticket, route direct to display
      context.push(
        Uri(
          path: '/queue-display',
          queryParameters: {
            'ticketNumber': ticketData['ticket_number'].toString(),
            'departmentId': ticketData['department_id'].toString(),
            'departmentName': ticketData['department_name'].toString(),
          },
        ).toString(),
      );
    } catch (e) {
      if (!mounted) return;

      // Filter out the 'Exception: ' string formatting
      final message = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Network error: Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EZInputField(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: ThemeHelpers.textInputDecoration(
                    // CHANGED: Updated hint to show tracking token format
                    hintText: 'e.g. K7N3P2XR',
                    contentPadding: const EdgeInsets.all(EZSpacing.md),
                    maxLength: 8,
                    currentLength: _currentLength,
                    extraSuffix: IconButton(
                      onPressed: _showQRScanner,
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      tooltip: 'Scan QR Code',
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleTrack(),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EZSpacing.md),
        SizedBox(
          width: double.infinity,
          child: EZButton(
            isSecondary: true,
            onPressed: _isLoading ? () {} : _handleTrack,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Track Ticket'),
          ),
        ),
      ],
    );
  }
}
