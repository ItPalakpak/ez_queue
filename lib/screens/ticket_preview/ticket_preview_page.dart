import 'dart:io';
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
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:path_provider/path_provider.dart';
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
    final tickets = ref.watch(queueTicketProvider);
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    if (tickets.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            const TopNavBar(),
            const Expanded(
              child: Center(
                child: Text('No ticket found. Please generate a ticket first.'),
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
              child: Center(
                child: RepaintBoundary(
                  key: _ticketKey,
                  child: Column(
                    children: tickets
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: EZSpacing.lg),
                              child: _buildTicketCard(context, t, isDark),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EZSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: EZButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveTicketAsImage(context),
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
                            Text('Save Ticket'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: EZSpacing.md),
              SizedBox(
                width: double.infinity,
                child: EZButton(
                  isSecondary: true,
                  onPressed: () => context.push('/queue-display'),
                  child: Text('View Queue Status'),
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
    // Construct QR data to match React kiosk format
    final List<String> qrDataArr = [];
    qrDataArr.add('Ticket: ${ticket.ticketNumber}');
    qrDataArr.add('Name: ${ticket.studentName}');
    
    final String userTypeLower = ticket.userType.toLowerCase();
    final String? ticketIdNumber = ticket.studentId ?? ticket.employeeId;
    
    if (userTypeLower == 'student' && ticket.studentId != null && ticket.studentId!.isNotEmpty) {
      qrDataArr.add('Student ID: ${ticket.studentId}');
    }
    if (userTypeLower == 'alumni' && ticket.studentId != null && ticket.studentId!.isNotEmpty) {
      qrDataArr.add('Alumni ID: ${ticket.studentId}');
    }
    if (userTypeLower == 'faculty' && ticket.employeeId != null && ticket.employeeId!.isNotEmpty) {
      qrDataArr.add('Staff/Faculty ID: ${ticket.employeeId}');
    }
    if (ticket.phone != null && ticket.phone!.isNotEmpty) {
      qrDataArr.add('Phone: ${ticket.phone}');
    }
    if (ticket.email != null && ticket.email!.isNotEmpty) {
      qrDataArr.add('Email: ${ticket.email}');
    }
    if (ticket.course != null && ticket.course!.isNotEmpty) {
      qrDataArr.add('Course: ${ticket.course}');
    }
    // CHANGED: Append tracking token to QR data for secure ticket lookup
    if (ticket.trackingToken != null && ticket.trackingToken!.isNotEmpty) {
      qrDataArr.add('Tracking: ${ticket.trackingToken}');
    }

    final String qrData = qrDataArr.join('\n');

    return EZCard(
      padding: EdgeInsets.zero,
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
                data: qrData,
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
            const SizedBox(height: EZSpacing.md),

            // Tracking Token
            if (ticket.trackingToken != null && ticket.trackingToken!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: EZSpacing.lg,
                  vertical: EZSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      'TRACKING CODE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: EZSpacing.xs),
                    Text(
                      ticket.trackingToken!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
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
            _buildDetailRow(context, 'Department:', ticket.departmentName),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(
              context,
              'Service Availed:',
              ticket.serviceName,
            ),
            if (ticket.purpose != null) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'Purpose:', ticket.purpose!),
            ],
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'User Type:', ticket.userType),
            if (ticket.course != null) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(
                context,
                'Course/Program:',
                ticket.course!,
              ),
            ],
            if (ticketIdNumber != null) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'ID Number:', ticketIdNumber),
            ],
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'Full Name:', ticket.studentName),
            const SizedBox(height: EZSpacing.sm),
            _buildDetailRow(context, 'Email:', ticket.email ?? ''),
            if (ticket.phone != null) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'Contact No.:', ticket.phone!),
            ],
            if (ticket.isPriority) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildDetailRow(context, 'Priority Queue:', 'Yes'),
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
          width: 130,
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

  /// Save ticket as image to device storage.
  Future<void> _saveTicketAsImage(BuildContext context) async {
    if (!mounted) return;

    // Store context-dependent values before async operations
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
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

      // Save to device storage using path_provider
      final String filePath = await _saveImageToStorage(pngBytes);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Ticket saved successfully!\n$filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
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

  /// Save image bytes to device storage and return the file path.
  Future<String> _saveImageToStorage(Uint8List imageBytes) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'EZQueue_Ticket_$timestamp.png';

    // Try to save to the Pictures directory on external storage (Android)
    // or to the application documents directory as fallback
    Directory? saveDir;

    if (Platform.isAndroid) {
      // On Android, save to /storage/emulated/0/Pictures/EZQueue/
      final Directory extDir = Directory(
        '/storage/emulated/0/Pictures/EZQueue',
      );
      if (!await extDir.exists()) {
        await extDir.create(recursive: true);
      }
      saveDir = extDir;
    } else {
      // iOS / other platforms: use application documents directory
      saveDir = await getApplicationDocumentsDirectory();
    }

    final File file = File('${saveDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);

    return file.path;
  }
}
