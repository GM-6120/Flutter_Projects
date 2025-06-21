import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soil_care_tech/pages/soil_data.dart';
import 'package:latlong2/latlong.dart';

class SoilApi {
  static const String baseUrl = 'http://localhost:5000'; // For web

  static Future<SoilData> analyzeSoil(LatLng coords) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'lat': coords.latitude, 'lng': coords.longitude}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return SoilData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  static getSoilHistory() {}
}
