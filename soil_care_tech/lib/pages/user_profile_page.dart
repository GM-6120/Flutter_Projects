import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  int _testCount = 0;
  DateTime? _lastTestDate;
  String? _profileImageUrl;

  final Color _primaryColor = Colors.green.shade700;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTestHistory();
    // _loadAchievements();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(_user!.uid).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'] ?? _user!.displayName ?? '';
        _profileImageUrl = userDoc['profileImageUrl'];
      });
    }
  }

  Future<void> _loadTestHistory() async {
    if (_user == null) return;

    QuerySnapshot tests = await _firestore
        .collection('tests')
        .where('userId', isEqualTo: _user!.uid)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    QuerySnapshot allTests = await _firestore
        .collection('tests')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    setState(() {
      _testCount = allTests.size;
      _lastTestDate = tests.docs.isNotEmpty
          ? (tests.docs.first['date'] as Timestamp).toDate()
          : null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_user == null || _image == null) return;

    try {
      final ref = _storage.ref().child('profile_images/${_user!.uid}');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImageUrl': url,
      });

      setState(() => _profileImageUrl = url);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': _nameController.text,
      });

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : _image != null
                      ? FileImage(_image!)
                      : null,
              backgroundColor: Colors.grey.shade200,
              child: _profileImageUrl == null && _image == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: _pickImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isEditing
            ? TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(
                _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'No Name',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
        Text(
          _user?.email ?? '',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Tests',
                  _testCount.toString(),
                  Icons.assignment,
                ),
                _buildStatItem(
                  'Member Since',
                  _user != null
                      ? DateFormat('MMM yyyy')
                          .format(_user!.metadata.creationTime!)
                      : 'N/A',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  'Last Test',
                  _lastTestDate != null
                      ? DateFormat('MMM d').format(_lastTestDate!)
                      : 'None',
                  Icons.history,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _testCount / 10, // Adjust based on your logic
              backgroundColor: Colors.grey.shade200,
              color: _primaryColor,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(_testCount / 10 * 100).toStringAsFixed(0)}% to next level',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Widget _buildAchievements() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
  //         child: Text(
  //           'Achievements',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.grey.shade800,
  //           ),
  //         ),
  //       ),
  //       SizedBox(
  //         height: 120,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           itemCount: _achievements.length,
  //           itemBuilder: (context, index) {
  //             final achievement = _achievements[index];
  //             return Container(
  //               width: 120,
  //               margin: const EdgeInsets.symmetric(horizontal: 8),
  //               child: Card(
  //                 elevation: 2,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(12),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(achievement['icon'],
  //                           color: _secondaryColor, size: 30),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         achievement['title'],
  //                         style: const TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                       const SizedBox(height: 8),
  //                       CircularPercentIndicator(
  //                         radius: 20,
  //                         lineWidth: 3,
  //                         percent: achievement['progress'],
  //                         progressColor: _primaryColor,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: _primaryColor),
              ),
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
                if (!_isEditing) _saveProfile();
              },
              child: Text(
                _isEditing ? 'Save Changes' : 'Edit Profile',
                style: TextStyle(color: _primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Implement share functionality
              },
              child: const Text('Share Profile'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsCard(),
            // const SizedBox(height: 16),
            // _buildAchievements(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
