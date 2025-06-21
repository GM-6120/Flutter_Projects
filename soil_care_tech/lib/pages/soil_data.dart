import 'package:latlong2/latlong.dart';

class SoilData {
  final double temperature;
  final double moisture;
  final String erosion;
  final DegradationLevel degradation;
  final LatLng coordinates;
  final LatLng nearestMatch;

  SoilData({
    required this.temperature,
    required this.moisture,
    required this.erosion,
    required this.degradation,
    required this.coordinates,
    required this.nearestMatch,
  });

  factory SoilData.fromJson(Map<String, dynamic> json) {
    return SoilData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      moisture: json['moisture']?.toDouble() ?? 0.0,
      erosion: json['erosion'] ?? 'Unknown',
      degradation: DegradationLevel.fromJson(json['degradation']),
      coordinates: LatLng(
        json['coordinates']['searched'][0]?.toDouble() ?? 0.0,
        json['coordinates']['searched'][1]?.toDouble() ?? 0.0,
      ),
      nearestMatch: LatLng(
        json['coordinates']['matched'][0]?.toDouble() ?? 0.0,
        json['coordinates']['matched'][1]?.toDouble() ?? 0.0,
      ),
    );
  }
}

class DegradationLevel {
  final int level;
  final String label;
  final double value;

  DegradationLevel({
    required this.level,
    required this.label,
    required this.value,
  });

  factory DegradationLevel.fromJson(Map<String, dynamic> json) {
    return DegradationLevel(
      level: json['level'] ?? 0,
      label: json['label'] ?? 'Unknown',
      value: json['value']?.toDouble() ?? 0.0,
    );
  }
}
