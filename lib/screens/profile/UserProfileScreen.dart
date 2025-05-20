// lib/screens/user/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../widgets/bottom_nav_bar.dart'; // Ensure this path is correct
import 'editProfileScreen.dart'; // Ensure this path is correct
// ManageSharedDoctorsScreen import is removed

// --- Define Colors (as before) ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color.fromARGB(255, 175, 182, 200);
const Color lightBgColor = Colors.white;
const Color separatorColor = Colors.black26;

// --- Asset Paths ---
const String profileAvatarPlaceholder =
    "assets/images/profile_avatar_placeholder.png";

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  List<String> _sharedDoctorNames = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controller for the doctor's email input dialog
  final TextEditingController _doctorEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndSharedDoctors();
  }

  @override
  void dispose() {
    _doctorEmailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDataAndSharedDoctors() async {
    if (!mounted) return;
    print("USER_PROFILE_SCREEN: Fetching user data and shared doctors...");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sharedDoctorNames = [];
    });

    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print(
        "USER_PROFILE_SCREEN: User not logged in during _fetchUserDataAndSharedDoctors.",
      );
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "User not logged in. Please log in to view your profile.";
        _isLoading = false;
      });
      return;
    }
    print("USER_PROFILE_SCREEN: Current user UID: ${currentUser.uid}");

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      print(
        "USER_PROFILE_SCREEN: Fetched user document. Exists: ${userDoc.exists}",
      );

      if (!mounted) return;
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _userData = data;
          });
        }

        if (data != null &&
            data.containsKey('sharedDoctorIds') &&
            data['sharedDoctorIds'] is List) {
          List<dynamic> doctorIdsDynamic = data['sharedDoctorIds'];
          List<String> doctorIds =
              doctorIdsDynamic.map((id) => id.toString()).toList();
          print(
            "USER_PROFILE_SCREEN: Found sharedDoctorIds in user data: $doctorIds",
          );

          List<String> tempDoctorNames = [];
          if (doctorIds.isNotEmpty) {
            for (String doctorId in doctorIds) {
              if (doctorId.trim().isEmpty) continue;
              print(
                "USER_PROFILE_SCREEN: Fetching doctor details for ID: $doctorId",
              );
              try {
                DocumentSnapshot doctorDoc =
                    await _firestore.collection('doctors').doc(doctorId).get();
                if (doctorDoc.exists) {
                  final doctorData = doctorDoc.data() as Map<String, dynamic>?;
                  tempDoctorNames.add(
                    doctorData?['fullName'] ?? 'Dr. (Name N/A)',
                  );
                  print(
                    "USER_PROFILE_SCREEN: Added doctor name: ${doctorData?['fullName']}",
                  );
                } else {
                  tempDoctorNames.add('Dr. (Profile Not Found)');
                  print(
                    "USER_PROFILE_SCREEN: Doctor profile not found for ID: $doctorId",
                  );
                }
              } catch (e) {
                print(
                  "USER_PROFILE_SCREEN: Error fetching individual doctor $doctorId: $e",
                );
                tempDoctorNames.add('Dr. (Error Loading)');
              }
            }
            if (mounted) {
              setState(() {
                _sharedDoctorNames = tempDoctorNames;
                print(
                  "USER_PROFILE_SCREEN: Updated displayed shared doctor names: $_sharedDoctorNames",
                );
              });
            }
          } else {
            print("USER_PROFILE_SCREEN: User's sharedDoctorIds list is empty.");
          }
        } else {
          print(
            "USER_PROFILE_SCREEN: No 'sharedDoctorIds' field found in user data or it's not a list.",
          );
        }
      } else {
        print(
          "USER_PROFILE_SCREEN: User profile document for ${currentUser.uid} does NOT exist.",
        );
        if (mounted) {
          setState(() {
            _errorMessage = "User profile not found in the database.";
          });
        }
      }
    } catch (e, s) {
      print("USER_PROFILE_SCREEN: Error in _fetchUserDataAndSharedDoctors: $e");
      print("USER_PROFILE_SCREEN: Stacktrace: $s");
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Failed to load profile data: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatBirthDate(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    try {
      DateTime date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return "Invalid Date";
    }
  }

  Widget _buildInfoSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: lightTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoDetail(String detail, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail,
            style: const TextStyle(
              color: darkTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isLast) const Divider(color: separatorColor, thickness: 0.8),
        ],
      ),
    );
  }

  void _navigateToEditProfile() async {
    if (_userData == null) {
      print("USER_PROFILE_SCREEN: Edit profile tapped but _userData is null.");
      return;
    }
    print(
      "USER_PROFILE_SCREEN: Navigating to EditProfileScreen with data: $_userData",
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData!),
      ),
    );
    print(
      "USER_PROFILE_SCREEN: Returned from EditProfileScreen with result: $result",
    );

    if (result == true && mounted) {
      print("USER_PROFILE_SCREEN: Refreshing data after profile edit.");
      _fetchUserDataAndSharedDoctors();
    }
  }

  Future<void> _showRequestShareDialog() async {
    _doctorEmailController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Request to Share Progress'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Enter the email address of the doctor you'd like to share your progress with. An administrator will review your request.",
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _doctorEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'doctor@example.com',
                    labelText: "Doctor's Email",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainAppColor),
              child: const Text(
                'Submit Request',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final String doctorEmail = _doctorEmailController.text.trim();
                if (doctorEmail.isEmpty || !doctorEmail.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                User? currentUser = _auth.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You must be logged in to make a request.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                  return;
                }

                try {
                  print(
                    "USER_PROFILE_SCREEN: Submitting sharing request for doctor email: $doctorEmail by user: ${currentUser.uid}",
                  );
                  await _firestore.collection('sharingRequests').add({
                    'userId': currentUser.uid,
                    'userEmail':
                        currentUser
                            .email, // Good to store for admin convenience
                    'doctorEmail': doctorEmail,
                    'status': 'pending', // Initial status
                    'requestedAt': FieldValue.serverTimestamp(),
                  });
                  print(
                    "USER_PROFILE_SCREEN: Sharing request submitted successfully.",
                  );
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request submitted for review!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print(
                    "USER_PROFILE_SCREEN: Error submitting sharing request: $e",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to submit request: ${e.toString()}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth * 0.15;

    return Scaffold(
      backgroundColor: mainAppColor,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainAppColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed:
                (_isLoading || _userData == null)
                    ? null
                    : _navigateToEditProfile,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _fetchUserDataAndSharedDoctors,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: mainAppColor,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
              : _userData == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Could not load profile data.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _fetchUserDataAndSharedDoctors,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: mainAppColor,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: avatarRadius),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: lightBgColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: avatarRadius + 20.0,
                            left: 25.0,
                            right: 25.0,
                            bottom: 25.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSectionTitle("Name"),
                              _buildInfoDetail(_userData?['fullName'] ?? 'N/A'),
                              const SizedBox(height: 15),

                              _buildInfoSectionTitle("User ID"),
                              _buildInfoDetail(_auth.currentUser?.uid ?? 'N/A'),
                              const SizedBox(height: 15),

                              _buildInfoSectionTitle("Information"),
                              _buildInfoDetail(_userData?['gender'] ?? 'N/A'),
                              _buildInfoDetail(
                                _formatBirthDate(
                                  _userData?['birthDate'] as Timestamp?,
                                ),
                              ),
                              _buildInfoDetail(
                                _userData?['phoneNumber']?.isNotEmpty == true
                                    ? _userData!['phoneNumber']
                                    : 'N/A',
                              ),
                              _buildInfoDetail(
                                _userData?['email'] ?? 'N/A',
                                isLast: true,
                              ),
                              const SizedBox(height: 20),

                              _buildInfoSectionTitle("Progress shared with"),
                              if (_sharedDoctorNames.isEmpty)
                                _buildInfoDetail(
                                  "Not sharing with any doctor",
                                  isLast: true,
                                )
                              else
                                ..._sharedDoctorNames.asMap().entries.map((
                                  entry,
                                ) {
                                  int idx = entry.key;
                                  String name = entry.value;
                                  return _buildInfoDetail(
                                    name,
                                    isLast:
                                        idx == _sharedDoctorNames.length - 1,
                                  );
                                }).toList(),
                              const SizedBox(
                                height: 15,
                              ), // Spacing before the button
                              Center(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.email_outlined,
                                    color: mainAppColor,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "Request to Share",
                                    style: TextStyle(
                                      color: mainAppColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: _showRequestShareDialog,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: mainAppColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: AssetImage(profileAvatarPlaceholder),
                        onBackgroundImageError: (e, s) {
                          print(
                            "USER_PROFILE_SCREEN: Failed to load profile image: $e",
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}