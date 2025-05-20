// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'editProfileScreen.dart'; // Your existing import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _screenIndex = 3;

  // --- Define Colors (keep as is) ---
  static const Color headerColor = Color(0xFF5A9AB8);
  static const Color primaryContentColor = Color(0xFF003366);
  static const Color secondaryContentColor = Color(0xFF5A7A9E);
  static const Color headerTextColor = Colors.white;
  static const Color avatarBackgroundColor = Color(0xFF4A88D0);
  static const Color avatarIconColor = Colors.white;
  static const Color dividerColor = Colors.grey;
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);

  // --- Profile Data State Variables ---
  late String profileName;
  late String profileId;
  late List<String> profileInfo; // [Gender, BirthDate, Phone, Email, Specialty]

  bool _isLoading = true;
  String? _errorMessage;

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    profileInfo = List.filled(5, ""); // Initialize with empty strings
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not logged in. Please log in again.";
          // Optionally, navigate to login screen
          // Navigator.of(context).pushReplacementNamed('/login');
        });
      }
      return;
    }

    try {
      DocumentSnapshot doctorDoc =
          await _firestore.collection('doctors').doc(currentUser.uid).get();

      if (doctorDoc.exists && mounted) {
        Map<String, dynamic> data = doctorDoc.data() as Map<String, dynamic>;

        // Format birthDate if it exists and is a Timestamp
        String birthDateStr = "N/A";
        if (data['birthDate'] != null && data['birthDate'] is Timestamp) {
          Timestamp dobTimestamp = data['birthDate'];
          birthDateStr = DateFormat('dd/MM/yyyy').format(dobTimestamp.toDate());
        } else if (data['birthDate'] is String) {
          // If it was already stored as a string (less ideal)
          birthDateStr = data['birthDate'];
        }

        setState(() {
          profileName =
              data['fullName'] ??
              "${data['firstName']} ${data['lastName']}" ??
              "N/A";
          profileId = currentUser.uid; // Or data['uid'] if you prefer
          profileInfo = [
            data['gender'] ?? "N/A",
            birthDateStr,
            data['phoneNumber'] ?? "N/A",
            data['email'] ?? currentUser.email ?? "N/A",
            data['specialty'] ??
                "Not Specified", // Assuming 'specialty' field exists
          ];
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Profile data not found. Please complete your profile.";
          // Fallback to some default or allow editing
          profileName = "Dr. User";
          profileId = currentUser.uid;
          profileInfo = [
            "N/A",
            "N/A",
            "N/A",
            currentUser.email ?? "N/A",
            "Not Specified",
          ];
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading profile: ${e.toString()}";
        });
      }
    }
  }

  // --- Navigation to Edit Profile (UPDATED) ---
  void _navigateToEditProfile() async {
    if (_isLoading) return; // Don't navigate if data isn't loaded

    final currentData = {
      'name': profileName,
      'id': profileId, // Pass ID for reference, though usually not editable
      'gender': profileInfo[0],
      'birthDate': profileInfo[1], // Pass as dd/MM/yyyy string
      'phone': profileInfo[2],
      'email': profileInfo[3],
      'specialty': profileInfo[4],
    };

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(initialProfileData: currentData),
      ),
    );

    if (result != null && mounted) {
      // Update state with the returned data
      setState(() {
        profileName = result['name'] ?? profileName;
        profileInfo = [
          result['gender'] ?? profileInfo[0],
          result['birthDate'] ?? profileInfo[1],
          result['phone'] ?? profileInfo[2],
          result['email'] ?? profileInfo[3],
          result['specialty'] ?? profileInfo[4],
        ];
      });

      // Persist the updated profile data to Firebase
      await _updateProfileInFirebase(result);
    }
  }

  Future<void> _updateProfileInFirebase(
    Map<String, dynamic> updatedData,
  ) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Not logged in. Cannot save profile.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Prepare data for Firestore update
      Map<String, dynamic> dataToUpdate = {
        'fullName': updatedData['name'],
        'gender': updatedData['gender'],
        'phoneNumber': updatedData['phone'],
        'email':
            updatedData['email'], // Note: Email in Auth might need separate update if changed
        'specialty': updatedData['specialty'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Handle birthDate: convert String "dd/MM/yyyy" back to Timestamp
      if (updatedData['birthDate'] != null &&
          updatedData['birthDate'] is String) {
        try {
          DateTime parsedDate = DateFormat(
            'dd/MM/yyyy',
          ).parse(updatedData['birthDate']);
          dataToUpdate['birthDate'] = Timestamp.fromDate(parsedDate);
        } catch (e) {
          print("Error parsing date for update: $e");
          // Handle error or skip updating date if format is wrong
        }
      }

      await _firestore
          .collection('doctors')
          .doc(currentUser.uid)
          .update(dataToUpdate);

      // If email was changed and you want to update Firebase Auth email:
      if (currentUser.email != updatedData['email']) {
        // This requires re-authentication or recent login for security.
        // await currentUser.updateEmail(updatedData['email']);
        // Consider the implications and Firebase security rules for email updates.
        print(
          "Email changed. Firebase Auth email update needs careful handling.",
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully in Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating profile in Firebase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Optionally, revert local state changes if Firebase update fails
        // await _fetchProfileData(); // Re-fetch to ensure consistency
      }
    }
  }

  // --- Helper Widget: Build Info Section (Keep as is) ---
  Widget _buildInfoSection({
    required String label,
    required List<String> details,
  }) {
    final theme = Theme.of(context);
    final effectivePrimaryColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : primaryContentColor;
    final effectiveSecondaryColor =
        theme.brightness == Brightness.dark
            ? Colors.white54
            : secondaryContentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: effectiveSecondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Divider(color: dividerColor, thickness: 0.8),
          const SizedBox(height: 10),
          ...details
              .map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    detail,
                    style: TextStyle(
                      color: effectivePrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // --- Bottom Nav Tap Handler (Keep as is) ---
  void _onItemTapped(int index) {
    if (index == _screenIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patients');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notes');
        break;
      case 3:
        // Already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : primaryContentColor;
    final effectiveHeaderTextColor =
        theme.brightness == Brightness.dark ? Colors.white : headerTextColor;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: headerColor,
          iconTheme: IconThemeData(color: effectiveHeaderTextColor),
          titleTextStyle: TextStyle(
            color: effectiveHeaderTextColor,
            fontSize: 20,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavBar(), // Keep consistent UI
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: headerColor,
          iconTheme: IconThemeData(color: effectiveHeaderTextColor),
          titleTextStyle: TextStyle(
            color: effectiveHeaderTextColor,
            fontSize: 20,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchProfileData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(), // Keep consistent UI
      );
    }

    // --- Main Profile UI ---
    return Scaffold(
      backgroundColor: headerColor, // Header area background
      body: Stack(
        children: [
          // --- Header (UPDATED Edit Button Action) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200, // Adjust as needed
            child: Container(
              color: headerColor,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0, // Adjusted for status bar
                    left: 25.0,
                    right: 25.0,
                    bottom: 35, // Space before content overlap
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Profile",
                                style: TextStyle(
                                  color: effectiveHeaderTextColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: _navigateToEditProfile,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: effectiveHeaderTextColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: effectiveHeaderTextColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: avatarBackgroundColor,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: avatarBackgroundColor,
                            child: Icon(
                              Icons.person,
                              color: avatarIconColor,
                              size: 55,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Content Area ---
          Positioned.fill(
            top: 165, // Start below the visual header part
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 25.0,
                  right: 25.0,
                  bottom: 90.0, // Space for bottom nav bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      style: TextStyle(
                        color: effectivePrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profileInfo.length > 4 &&
                        profileInfo[4].isNotEmpty &&
                        profileInfo[4] != "Not Specified")
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          profileInfo[4], // Specialty
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color
                                    ?.withOpacity(0.7) ??
                                secondaryContentColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),

                    _buildInfoSection(label: "Doctor ID", details: [profileId]),

                    _buildInfoSection(
                      label: "Contact Information",
                      details: [
                        "Gender: ${profileInfo[0]}",
                        "Birth Date: ${profileInfo[1]}",
                        "Phone: ${profileInfo[2]}",
                        "Email: ${profileInfo[3]}",
                      ],
                    ),

                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Settings'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: secondaryContentColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Theme.of(context).cardColor,
                        side: BorderSide(color: Colors.grey.shade300),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        // Implement actual logout
                        await _auth.signOut();
                        if (mounted) {
                          // Navigate to login screen and remove all previous routes
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Helper for Bottom Nav Bar to reduce duplication in build method
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Notes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _screenIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: bottomNavColor,
        selectedItemColor: bottomNavSelectedColor,
        unselectedItemColor: bottomNavUnselectedColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 1,
        unselectedFontSize: 1,
        elevation: 5,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
    );
  }
}