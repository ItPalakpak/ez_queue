import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ez_queue/models/queue_ticket.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/app_logo.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_dialog.dart';

/// Reusable modal component for displaying comprehensive details of a tracked queue ticket.
/// Fully theme-aware and responsive across light, dark, and custom variants.
class TrackedTicketDetailsModal extends StatelessWidget {
  final QueueTicket ticket;

  const TrackedTicketDetailsModal({
    super.key,
    required this.ticket,
  });

  /// Static helper to launch the dialog easily from any context.
  static Future<void> show(BuildContext context, QueueTicket ticket) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TrackedTicketDetailsModal(ticket: ticket),
    );
  }

  /// Construct standardized QR code payload matching kiosk format.
  String _buildQrData() {
    final List<String> qrDataArr = [];
    qrDataArr.add('Ticket: ${ticket.ticketNumber}');

    if (ticket.nameBreakdown != null && ticket.nameBreakdown!['last_name'] != null) {
      qrDataArr.add('Last Name: ${ticket.nameBreakdown!['last_name']}');
      qrDataArr.add('First Name: ${ticket.nameBreakdown!['first_name']}');
      if (ticket.nameBreakdown!['middle_name'] != null && ticket.nameBreakdown!['middle_name']!.isNotEmpty) {
        qrDataArr.add('Middle Name: ${ticket.nameBreakdown!['middle_name']}');
      }
      if (ticket.nameBreakdown!['suffix'] != null && ticket.nameBreakdown!['suffix']!.isNotEmpty) {
        qrDataArr.add('Suffix: ${ticket.nameBreakdown!['suffix']}');
      }
    } else {
      qrDataArr.add('Name: ${ticket.clientName}');
    }

    final String userTypeLower = ticket.userType.toLowerCase();

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
      qrDataArr.add('Course: ${ticket.course}${ticket.major != null && ticket.major!.isNotEmpty ? ' (${ticket.major})' : ''}');
    }
    if (ticket.trackingToken != null && ticket.trackingToken!.isNotEmpty) {
      qrDataArr.add('Tracking: ${ticket.trackingToken}');
    }

    return qrDataArr.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<EZThemeExtension>();
    final shadowColor = ext?.shadowColor ?? theme.colorScheme.onSurface;
    final qrData = _buildQrData();
    final String? ticketIdNumber = ticket.studentId ?? ticket.employeeId;

    // Status badge color selection
    Color statusColor;
    String statusLabel = ticket.status.toUpperCase();
    if (ticket.status == 'serving') {
      statusColor = theme.colorScheme.primary;
      statusLabel = 'NOW SERVING';
    } else if (ticket.status == 'waiting') {
      statusColor = Colors.amber.shade700;
      statusLabel = 'WAITING';
    } else if (ticket.status == 'completed') {
      statusColor = Colors.green;
      statusLabel = 'COMPLETED';
    } else if (ticket.status == 'cancelled') {
      statusColor = theme.colorScheme.error;
      statusLabel = 'CANCELLED';
    } else {
      statusColor = theme.colorScheme.secondary;
    }

    return EZDialog(
      padding: const EdgeInsets.all(EZSpacing.lg),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const AppLogo(height: 36, width: 36),
              const SizedBox(width: EZSpacing.sm),
              Text(
                'Ticket Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Priority header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EZSpacing.md,
                    vertical: EZSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (ticket.isPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EZSpacing.md,
                      vertical: EZSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
                      border: Border.all(color: theme.colorScheme.error, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Text(
                          'PRIORITY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: EZSpacing.md),

            // Large Ticket Number Header
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: EZSpacing.md,
                horizontal: EZSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                border: Border.all(color: shadowColor, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    'TICKET NUMBER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: EZSpacing.xs),
                  Text(
                    ticket.ticketNumber,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (ticket.trackingToken != null && ticket.trackingToken!.isNotEmpty) ...[
                    const SizedBox(height: EZSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tracking: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          ticket.trackingToken!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'JetBrains Mono',
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: EZSpacing.lg),

            // QR Code display
            Center(
              child: Container(
                padding: const EdgeInsets.all(EZSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 160.0,
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
            ),
            const SizedBox(height: EZSpacing.lg),

            // Section: Department & Service Details
            _buildSectionHeader(context, 'DEPARTMENT & SERVICE'),
            const SizedBox(height: EZSpacing.xs),
            _buildInfoTile(
              context,
              icon: Icons.apartment,
              label: 'Department',
              value: ticket.departmentName.isNotEmpty ? ticket.departmentName : 'Department',
            ),
            _buildInfoTile(
              context,
              icon: Icons.design_services,
              label: 'Primary Service',
              value: ticket.serviceName.isNotEmpty ? ticket.serviceName : 'Service',
            ),
            if (ticket.purpose != null && ticket.purpose!.isNotEmpty)
              _buildInfoTile(
                context,
                icon: Icons.description_outlined,
                label: 'Purpose',
                value: ticket.purpose!,
              ),
            if (ticket.quantity > 1)
              _buildInfoTile(
                context,
                icon: Icons.tag,
                label: 'Quantity',
                value: '${ticket.quantity}',
              ),

            // Section: Add-on Services (if any)
            if (ticket.additionalServices != null &&
                ticket.additionalServices!.where((s) => s is Map && s['is_primary'] != true).isNotEmpty) ...[
              const SizedBox(height: EZSpacing.sm),
              _buildSectionHeader(context, 'INCLUDED ADD-ON SERVICES'),
              const SizedBox(height: EZSpacing.xs),
              ...ticket.additionalServices!
                  .where((s) => s is Map && s['is_primary'] != true)
                  .map((svcItem) {
                final svc = svcItem as Map;
                final svcName = svc['name']?.toString() ?? 'Add-on Service';
                final svcPrefix = svc['prefix'] != null && svc['prefix'].toString().isNotEmpty
                    ? ' (${svc['prefix']})'
                    : '';

                return _buildInfoTile(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Add-on',
                  value: '$svcName$svcPrefix',
                );
              }),
            ],

            const SizedBox(height: EZSpacing.md),

            // Section: Client Details
            _buildSectionHeader(context, 'CLIENT INFORMATION'),
            const SizedBox(height: EZSpacing.xs),
            _buildInfoTile(
              context,
              icon: Icons.person_outline,
              label: 'Client Name',
              value: ticket.clientName,
            ),
            _buildInfoTile(
              context,
              icon: Icons.badge_outlined,
              label: 'User Type',
              value: ticket.userType.toUpperCase(),
            ),
            if (ticketIdNumber != null && ticketIdNumber.isNotEmpty)
              _buildInfoTile(
                context,
                icon: Icons.credit_card,
                label: 'ID Number',
                value: ticketIdNumber,
              ),
            if (ticket.course != null && ticket.course!.isNotEmpty)
              _buildInfoTile(
                context,
                icon: Icons.school_outlined,
                label: 'Course/Program',
                value: '${ticket.course!}${ticket.major != null && ticket.major!.isNotEmpty ? ' (${ticket.major})' : ''}',
              ),
            if (ticket.email != null && ticket.email!.isNotEmpty)
              _buildInfoTile(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: ticket.email!,
              ),
            if (ticket.phone != null && ticket.phone!.isNotEmpty)
              _buildInfoTile(
                context,
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: ticket.phone!,
              ),

            const SizedBox(height: EZSpacing.md),

            // Section: Timestamp & Metadata
            _buildSectionHeader(context, 'TRANSACTION INFO'),
            const SizedBox(height: EZSpacing.xs),
            _buildInfoTile(
              context,
              icon: Icons.access_time,
              label: 'Generated At',
              value: _formatDate(ticket.createdAt),
            ),
          ],
        ),
      ),
      actions: [
        EZButton(
          isSecondary: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: EZSpacing.sm, bottom: EZSpacing.xs),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: EZSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: EZSpacing.md, vertical: EZSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: EZSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: EZSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
