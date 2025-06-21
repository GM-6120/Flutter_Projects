import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:soil_care_tech/pages/soil_data.dart';
import 'package:soil_care_tech/pages/soil_report_popup.dart';
import 'package:soil_care_tech/services/soil_api.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _coordController = TextEditingController();
  final List<SoilData> _soilHistory = [];
  bool _isLoading = false;
  bool _isFullscreen = false;
  final Random _random = Random();

  // Narowal District boundary (approximate)
  static const _boundaryCenter = latlng.LatLng(32.0924, 74.8750);
  // Expanded boundary coordinates (Zafarwal + Badomalhi + Narowal)
  static const double _minLat = 31.85; // Previous: 31.97
  static const double _maxLat = 32.45; // Previous: 32.3
  static const double _minLng = 74.55; // Previous: 74.65
  static const double _maxLng = 75.25; // Previous: 75.1

  bool _isWithinBoundary(latlng.LatLng point) {
    return point.latitude >= _minLat &&
        point.latitude <= _maxLat &&
        point.longitude >= _minLng &&
        point.longitude <= _maxLng;
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await SoilApi.getSoilHistory();
      setState(() => _soilHistory.addAll(history));
    } catch (e) {
      // Silently fail - don't show error for empty history
      if (_soilHistory.isEmpty) return;
      _showErrorDialog('History Error', 'Failed to load history');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeSoil() async {
    final input = _coordController.text.trim();

    // Add this check for empty input
    if (input.isEmpty) {
      _showErrorDialog('Empty Input', 'Please select or enter coordinates');
      return;
    }

    final parts = input.split(',');
    if (parts.length != 2) {
      _showErrorDialog(
          'Invalid Format', 'Use "lat,lng" format (e.g. 32.0924, 74.8750)');
      return;
    }

    try {
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      final point = latlng.LatLng(lat, lng);

      // Boundary check for manual input
      if (!_isWithinBoundary(point)) {
        _showErrorDialog(
            'Out of Boundary',
            'Coordinates must be within:\n'
                'Lat: 31.97°-32.3°\n'
                'Lng: 74.65°-75.1°');
        return;
      }

      setState(() => _isLoading = true);
      final soilData = await SoilApi.analyzeSoil(point);

      // Generate dummy values
      final dummySoilData = SoilData(
        temperature: 25.0 + _random.nextDouble() * 10,
        moisture: 10.0 + _random.nextDouble() * 20,
        erosion: soilData.erosion,
        degradation: soilData.degradation,
        coordinates: soilData.coordinates,
        nearestMatch: soilData.nearestMatch,
      );

      setState(() {
        _isLoading = false;
        _soilHistory.insert(0, dummySoilData);
      });

      _showSoilReport(dummySoilData);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Analysis Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showSoilReport(SoilData soilData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SoilReportPopup(
        soilData: soilData,
        coordinates: soilData.coordinates,
      ),
    );
  }

  Widget _buildSoilHistoryCard(SoilData soilData, BuildContext context) {
    Color severityColor;
    switch (soilData.degradation.level) {
      case 3:
        severityColor = Colors.red;
        break;
      case 2:
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSoilReport(soilData),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      soilData.degradation.label,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSoilParameter(
                    '${soilData.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                  _buildSoilParameter(
                    '${soilData.moisture.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildSoilParameter(
                    soilData.erosion,
                    Icons.landscape,
                    Colors.brown,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${soilData.coordinates.latitude.toStringAsFixed(4)}, '
                    '${soilData.coordinates.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilParameter(String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(value,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Text(
            icon == Icons.thermostat
                ? 'Temperature'
                : icon == Icons.water_drop
                    ? 'Moisture'
                    : 'Erosion',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4), // Added margin below header
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Soil Care Tech',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              SizedBox(height: 4),
              Text('Monitor and analyze soil degradation',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.white, size: 30),
            onPressed: () => Navigator.pushNamed(context, '/UserProfile'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'fullscreen',
            mini: true,
            onPressed: () {
              setState(() => _isFullscreen = !_isFullscreen);
              if (!_isFullscreen) {
                _mapController.move(_boundaryCenter, 13.0);
              }
            },
            child:
                Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'home',
            mini: true,
            onPressed: () => _mapController.move(_boundaryCenter, 13.0),
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header (hidden in fullscreen mode)
          if (!_isFullscreen) _buildHeader(),
          // Map section (expands in fullscreen mode
          Expanded(
            flex: _isFullscreen ? 1 : 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        const latlng.LatLng(32.0924, 74.8750), // Narowal center
                    initialZoom: 12.0,
                    onMapEvent: (mapEvent) {
                      if (mapEvent is MapEventMove) {
                        final center = mapEvent.camera.center;
                        final clampedLat =
                            center.latitude.clamp(_minLat, _maxLat);
                        final clampedLng =
                            center.longitude.clamp(_minLng, _maxLng);

                        if (center.latitude != clampedLat ||
                            center.longitude != clampedLng) {
                          _mapController.move(
                            latlng.LatLng(clampedLat, clampedLng),
                            mapEvent.camera.zoom,
                          );
                        }
                      }
                    },
                    onTap: (tapPos, point) {
                      if (!_isWithinBoundary(point)) {
                        _showErrorDialog(
                          'Out of Boundary',
                          'Please select coordinates within Narowal District:\n'
                              'Latitude: $_minLat° to $_maxLat°\n'
                              'Longitude: $_minLng° to $_maxLng°',
                        );
                        return;
                      }
                      setState(() {
                        _coordController.text =
                            '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
                      });
                    },
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: [
                            latlng.LatLng(_minLat, _minLng),
                            latlng.LatLng(_minLat, _maxLng),
                            latlng.LatLng(_maxLat, _maxLng),
                            latlng.LatLng(_maxLat, _minLng),
                          ],
                          color: Colors.blue.withOpacity(0.1),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'fullscreen',
                        mini: true,
                        onPressed: () =>
                            setState(() => _isFullscreen = !_isFullscreen),
                        child: Icon(_isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Input/History section (hidden in fullscreen mode)
          if (!_isFullscreen) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _coordController,
                decoration: InputDecoration(
                  hintText: 'Enter Coordinates (lat,lng)',
                  prefixIcon: const Icon(Icons.pin_drop, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeSoil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Analyze Soil"),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Analysis History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _soilHistory.isEmpty
                        ? const Center(
                            child: Text('No analysis history available'))
                        : ListView.builder(
                            itemCount: _soilHistory.length,
                            itemBuilder: (context, index) {
                              return _buildSoilHistoryCard(
                                  _soilHistory[index], context);
                            },
                          ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _isFullscreen
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.green.shade700,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                if (index == 1) _navigateTo('/history');
                if (index == 2) _navigateTo('/settings');
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: 'History'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
    );
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }
}
