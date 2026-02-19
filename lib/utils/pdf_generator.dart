import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ez_queue/models/queue_ticket.dart';

/// Utility class for generating PDF tickets with QR codes.
class PDFGenerator {
  /// Generate and display PDF ticket.
  static Future<void> generateTicketPDF(QueueTicket ticket) async {
    final pdf = pw.Document();

    // Generate QR code data
    final qrData = ticket.ticketNumber;

    // Create QR code image
    final qrImage = await _generateQRCodeImage(qrData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                'EZQueue Ticket',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // QR Code
              if (qrImage != null)
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(qrImage),
                    width: 200.0,
                    height: 200.0,
                  ),
                ),
              pw.SizedBox(height: 20),

              // Ticket Number
              pw.Text(
                'Ticket Number: ${ticket.ticketNumber}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Details
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Department:', ticket.department),
                    _buildDetailRow('Services:', ticket.services.join(', ')),
                    _buildDetailRow('User Type:', ticket.userType),
                    if (ticket.idNumber != null)
                      _buildDetailRow('ID Number:', ticket.idNumber!),
                    _buildDetailRow('Full Name:', ticket.fullName),
                    _buildDetailRow('Email:', ticket.email),
                    if (ticket.isPWD) _buildDetailRow('PWD:', 'Yes'),
                    if (ticket.isPWD && ticket.pwdSpecification != null)
                      _buildDetailRow(
                        'PWD Specification:',
                        ticket.pwdSpecification!,
                      ),
                    _buildDetailRow(
                      'Queue Position:',
                      '${ticket.queuePosition}',
                    ),
                    _buildDetailRow(
                      'Estimated Wait:',
                      '${ticket.estimatedWaitMinutes} minutes',
                    ),
                    _buildDetailRow(
                      'Date:',
                      '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                    ),
                    _buildDetailRow(
                      'Time:',
                      '${ticket.createdAt.hour.toString().padLeft(2, '0')}:${ticket.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Try to show PDF preview, fallback to saving and sharing if printing is not available
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // If printing plugin is not available, save PDF to file and share
      try {
        final pdfBytes = await pdf.save();
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
          '${directory.path}/EZQueue_Ticket_${ticket.ticketNumber}.pdf',
        );
        await file.writeAsBytes(pdfBytes);

        // Share the PDF file
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Your EZQueue Ticket: ${ticket.ticketNumber}');
      } catch (shareError) {
        throw Exception(
          'Unable to generate PDF. Please rebuild the app: flutter clean && flutter pub get && flutter run. Error: $e',
        );
      }
    }
  }

  /// Build a detail row in the PDF.
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  /// Generate QR code as image bytes.
  static Future<Uint8List?> _generateQRCodeImage(String data) async {
    try {
      final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
        // Background color is handled by the canvas
      );

      final picRecorder = ui.PictureRecorder();
      final canvas = Canvas(picRecorder);
      const size = 200.0;

      // Fill background with white
      final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), backgroundPaint);

      painter.paint(canvas, const Size(size, size));
      final picture = picRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      // If QR code generation fails, return null
      return null;
    }
  }
}
