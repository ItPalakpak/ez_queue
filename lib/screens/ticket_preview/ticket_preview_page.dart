import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';

/// Ticket preview page displaying the full ticket with QR code.
/// Allows users to save the ticket as an image.
class TicketPreviewPage extends ConsumerStatefulWidget {
  const TicketPreviewPage({super.key});

  @override
  ConsumerState<TicketPreviewPage> createState() => _TicketPreviewPageState();
}

class _TicketPreviewPageState extends ConsumerState<TicketPreviewPage> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(queueTicketProvider);
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket Preview')),
        body: const Center(
          child: Text('No ticket found. Please generate a ticket first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isSaving ? null : () => _saveTicketAsImage(context),
            tooltip: 'Save Ticket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EZSpacing.lg),
        child: Center(
          child: RepaintBoundary(
            key: _ticketKey,
            child: _buildTicketCard(context, ticket, isDark),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EZSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveTicketAsImage(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: EZSpacing.md,
                      horizontal: EZSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download),
                            const SizedBox(width: EZSpacing.sm),
                            Text(
                              'Save Ticket',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: EZSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/queue-display'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: EZSpacing.md,
                      horizontal: EZSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'View Queue Status',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the ticket card widget.
  Widget _buildTicketCard(BuildContext context, dynamic ticket, bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EZSpacing.radiusLg),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(EZSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(EZSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with logo and title
            const AppLogo(height: 80, width: 80),
            const SizedBox(height: EZSpacing.lg),
            Text(
              'EZQueue Ticket',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: EZSpacing.xl),

            // QR Code
            Container(
              padding: const EdgeInsets.all(EZSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
              ),
              child: QrImageView(
                data: ticket.ticketNumber,
                version: QrVersions.auto,
                size: 200.0,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF000000),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            const SizedBox(height: EZSpacing.xl),

            // Ticket Number
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: EZSpacing.lg,
                vertical: EZSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
              ),
              child: Text(
                'Ticket Number: ${ticket.ticketNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: EZSpacing.xl),

            // Divider
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: EZSpacing.xl),

            // Ticket Details
            _buildDetailRow(context, 'Department:', ticket.department),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'Services:', ticket.services.join(', ')),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'User Type:', ticket.userType),
            if (ticket.idNumber != null) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'ID Number:', ticket.idNumber!),
            ],
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'Full Name:', ticket.fullName),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'Email:', ticket.email),
            if (ticket.isPWD) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'PWD:', 'Yes'),
              if (ticket.pwdSpecification != null) ...[
                const SizedBox(height: EZSpacing.sm),
                _buildDetailRow(
                  context,
                  'PWD Specification:',
                  ticket.pwdSpecification!,
                ),
              ],
            ],
            const SizedBox(height: EZSpacing.xl),

            // Divider
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: EZSpacing.xl),

            // Date and Time
            _buildDetailRow(
              context,
              'Date:',
              '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
            ),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(
              context,
              'Time:',
              '${ticket.createdAt.hour.toString().padLeft(2, '0')}:${ticket.createdAt.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }

  /// Build a detail row in the ticket.
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  /// Save ticket as image to gallery.
  Future<void> _saveTicketAsImage(BuildContext context) async {
    if (!mounted) return;

    // Store context-dependent values before async operations
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      // Request permission if needed (gal handles this automatically on newer Android/iOS)
      // Capture the widget as an image
      final RenderRepaintBoundary? boundary =
          _ticketKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Unable to capture ticket image');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Unable to convert image to bytes');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to gallery (PNG format is widely supported)
      await Gal.putImageBytes(pngBytes);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Ticket saved to gallery successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error saving ticket: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
