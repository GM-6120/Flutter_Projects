import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:soil_care_tech/pages/full_report_page.dart';
import 'package:soil_care_tech/pages/soil_data.dart';

class SoilReportPopup extends StatelessWidget {
  final SoilData soilData;
  final LatLng coordinates;

  const SoilReportPopup({
    super.key,
    required this.soilData,
    required this.coordinates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soil Analysis Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // Metrics in a more visual layout
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricTile(
                context,
                'Temperature',
                '${soilData.temperature.toStringAsFixed(1)}°C',
                Icons.thermostat,
                Colors.orange[700]!,
                Colors.orange[50]!,
              ),
              _buildMetricTile(
                context,
                'Moisture',
                '${soilData.moisture.toStringAsFixed(1)}%',
                Icons.water_drop,
                Colors.blue[700]!,
                Colors.blue[50]!,
              ),
              _buildMetricTile(
                context,
                'Erosion',
                soilData.erosion,
                Icons.landscape,
                Colors.brown[700]!,
                Colors.brown[50]!,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Degradation card with improved visual hierarchy
          _buildDegradationCard(soilData.degradation),
          const SizedBox(height: 16),

          // Full report button
          ElevatedButton.icon(
            icon: const Icon(Icons.assignment),
            label: const Text('View Full Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Updated navigation using pushNamed with arguments
              Navigator.pushNamed(
                context,
                '/full-report',
                arguments: {
                  'soilData': soilData,
                  'coordinates': coordinates,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDegradationCard(DegradationLevel degradation) {
    Color color;
    String severity;

    switch (degradation.level) {
      case 1:
        color = Colors.green;
        severity = 'Low';
      case 2:
        color = Colors.orange;
        severity = 'Moderate';
      case 3:
        color = Colors.red;
        severity = 'High';
      default:
        color = Colors.grey;
        severity = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: color),
              const SizedBox(width: 8),
              Text(
                'Soil Degradation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEVEL',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    severity,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALUE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    degradation.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Chip(
                    label: Text(degradation.label),
                    backgroundColor: color.withOpacity(0.2),
                    labelStyle: TextStyle(color: color),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
