import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:soil_care_tech/pages/soil_data.dart';
import 'dart:typed_data';

class FullReportPage extends StatelessWidget {
  final SoilData soilData;

  const FullReportPage(
      {super.key, required this.soilData, required LatLng coordinates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Health Report'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generateAndSharePDF(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("Soil Parameters"),
            _buildParameterCard(
              title: "Temperature",
              value: "${soilData.temperature}°C",
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
            _buildParameterCard(
              title: "Moisture",
              value: "${soilData.moisture}%",
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            _buildParameterCard(
              title: "Erosion",
              value: soilData.erosion,
              icon: Icons.landscape,
              color: Colors.brown,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Degradation Analysis"),
            _buildDegradationCard(soilData.degradation),
            const SizedBox(height: 20),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Soil Analysis Location",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now()),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Searched Coordinates: ${soilData.coordinates.latitude.toStringAsFixed(4)}, "
              "${soilData.coordinates.longitude.toStringAsFixed(4)}",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Nearest Match: ${soilData.nearestMatch.latitude.toStringAsFixed(4)}, "
              "${soilData.nearestMatch.longitude.toStringAsFixed(4)}",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildParameterCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDegradationCard(DegradationLevel degradation) {
    Color color;
    switch (degradation.level) {
      case 1:
        color = Colors.green;
        break;
      case 2:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              degradation.level == 3
                  ? Icons.warning
                  : degradation.level == 2
                      ? Icons.info
                      : Icons.check_circle,
              color: color,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Degradation Level",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    degradation.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    "Value: ${degradation.value}",
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                  if (degradation.level == 3) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Immediate action recommended",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text("Download Full Report"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _generateAndSharePDF(context),
      ),
    );
  }

  Future<void> _generateAndSharePDF(BuildContext context) async {
    try {
      final pdfBytes = await generatePDF();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'Soil_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Soil Health Report',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}'),
              pw.Text('Searched Coordinates: '
                  '${soilData.coordinates.latitude.toStringAsFixed(4)}, '
                  '${soilData.coordinates.longitude.toStringAsFixed(4)}'),
              pw.Text('Nearest Match: '
                  '${soilData.nearestMatch.latitude.toStringAsFixed(4)}, '
                  '${soilData.nearestMatch.longitude.toStringAsFixed(4)}'),
              pw.Divider(),
              pw.Text(
                'Soil Parameters',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfRow(
                  'Temperature', '${soilData.temperature}°C', font, fontBold),
              _buildPdfRow('Moisture', '${soilData.moisture}%', font, fontBold),
              _buildPdfRow('Erosion', soilData.erosion, font, fontBold),
              pw.Divider(),
              pw.Text(
                'Degradation Analysis',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPdfRow('Level', soilData.degradation.label, font, fontBold),
              _buildPdfRow('Value', soilData.degradation.value.toString(), font,
                  fontBold),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfRow(
      String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(font: fontBold),
          ),
          pw.Text(value, style: pw.TextStyle(font: font)),
        ],
      ),
    );
  }
}
