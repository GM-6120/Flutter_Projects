import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const _historyLimit = 20;
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  List<QueryDocumentSnapshot> _filteredHistory = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  bool _showFilters = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadHistoryData({bool loadMore = false}) async {
    if (_currentUser == null || _currentUser!.uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view history')),
        );
      }
      return;
    }

    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _filteredHistory = [];
          _lastDocument = null;
        });
      }

      Query query = _firestore
          .collection('soil_analyses')
          .where('userId', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(_historyLimit);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot =
          await query.get(const GetOptions(source: Source.serverAndCache));

      if (!mounted) return;

      setState(() {
        if (snapshot.docs.isEmpty) {
          _hasMoreData = false;
        } else {
          _filteredHistory.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;
        }
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint('Firestore Error [${e.code}]: ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'failed-precondition'
              ? 'Database index missing - tap to create'
              : 'Error: ${e.message}'),
          action: e.code == 'failed-precondition'
              ? SnackBarAction(
                  label: 'FIX NOW',
                  onPressed: _createFirestoreIndex,
                )
              : null,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Unexpected Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createFirestoreIndex() async {
    const indexUrl =
        'https://console.firebase.google.com/v1/r/project/soil-care-tech-a0428/firestore/indexes?create_composite=Clpwcm9qZWN0cy9zb2lsLWNhcmUtdGVjaC1hMDQyOC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvc29pbF9hbmFseXNlcy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgl0aW1lc3RhbXAQAhoMCghfX25hbWVfXxAC';
    try {
      if (await canLaunchUrl(Uri.parse(indexUrl))) {
        await launchUrl(Uri.parse(indexUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch browser')),
        );
      }
      debugPrint('Error launching URL: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoading && _hasMoreData) {
        _loadHistoryData(loadMore: true);
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    if (_filteredHistory.isEmpty) return;

    setState(() {
      _filteredHistory = _filteredHistory.where((doc) {
        final test = doc.data() as Map<String, dynamic>;
        final testDate = (test['timestamp'] as Timestamp).toDate();

        final matchesSearch = _searchQuery.isEmpty ||
            (test['location']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (test['description']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);

        final matchesDateRange = _selectedDateRange == null ||
            (testDate.isAfter(_selectedDateRange!.start) &&
                testDate.isBefore(_selectedDateRange!.end));

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDateRange = null;
      _searchQuery = '';
      _loadHistoryData();
    });
  }

  String _getDegradationLabel(int level) {
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Moderate';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  void _viewReport(Map<String, dynamic> testData) {
    Navigator.pushNamed(
      context,
      '/full-report',
      arguments: {
        'soilData': testData,
        'coordinates': LatLng(
          testData['latitude'] ?? 0.0,
          testData['longitude'] ?? 0.0,
        ),
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser == null
                ? 'Please sign in to view your history'
                : 'No test results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty || _selectedDateRange != null)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          if (_currentUser == null)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign In'),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Text('Soil Test History',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              SizedBox(height: 4),
              Text('Your analysis timeline',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green.shade700,
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 0) Navigator.pop(context);
        if (index == 2) Navigator.pushNamed(context, '/settings');
      },
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 150 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by location or notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearFilters,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _selectedDateRange == null
                  ? 'Select Date Range'
                  : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(QueryDocumentSnapshot doc, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final date = timestamp?.toDate();
    final degradation = data['degradation'] ?? 0;

    Color statusColor;
    switch (degradation) {
      case 3:
        statusColor = Colors.red;
      case 2:
        statusColor = Colors.orange;
      default:
        statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewReport(data),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'No date',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDegradationLabel(degradation),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSoilParameter(
                    '${data['temperature']?.toStringAsFixed(1) ?? '--'}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                  _buildSoilParameter(
                    '${data['moisture']?.toStringAsFixed(1) ?? '--'}%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildSoilParameter(
                    data['erosion'] ?? '--',
                    Icons.landscape,
                    Colors.brown,
                  ),
                ],
              ),
              if (data['coordinates'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${data['coordinates']['latitude'].toStringAsFixed(4)}, '
                      '${data['coordinates']['longitude'].toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
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
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            icon == Icons.thermostat
                ? 'Temp'
                : icon == Icons.water_drop
                    ? 'Moisture'
                    : 'Erosion',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
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
          _buildHeader(),
          _buildFilterPanel(),
          if (_isLoading && _filteredHistory.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filteredHistory.isEmpty)
            Expanded(child: _buildEmptyState())
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHistoryData,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _filteredHistory.length + (_hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _filteredHistory.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildHistoryItem(_filteredHistory[index], index);
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
