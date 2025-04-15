// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'editProfileScreen.dart'; // <-- Import the new screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _screenIndex = 3;

  // --- Define Colors (keep as is) ---
  static const Color headerColor = Color(0xFF5A9AB8);
  // ... other colors
  static const Color primaryContentColor = Color(0xFF003366);
  static const Color secondaryContentColor = Color(0xFF5A7A9E);
  static const Color headerTextColor = Colors.white;
  static const Color avatarBackgroundColor = Color(0xFF4A88D0);
  static const Color avatarIconColor = Colors.white;
  static const Color dividerColor = Colors.grey;
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);

  // --- Profile Data State Variables (Make them updatable) ---
  // Use late if initializing in initState or provide defaults
  late String profileName;
  late String profileId;
  late List<String>
  profileInfo; // List: [Gender, BirthDate, Phone, Email, Specialty]
  // late String doctorName; // Removed, assuming this is doctor's own profile

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data (replace with actual data loading later)
    _loadProfileData();
  }

  void _loadProfileData() {
    // Simulate loading data
    setState(() {
      profileName = "Dr. Evelyn Reed";
      profileId = "#DR12345";
      profileInfo = [
        "Female", // Gender (Index 0)
        "11/07/1980", // BirthDate (Index 1) - Use consistent format like dd/MM/yyyy
        "079-123-4567", // Phone (Index 2)
        "e.reed.clinic@mail.com", // Email (Index 3)
        "Psychiatrist", // Specialty (Index 4)
      ];
    });
  }

  // --- Navigation to Edit Profile (UPDATED) ---
  void _navigateToEditProfile() async {
    // Prepare current data to pass
    final currentData = {
      'name': profileName,
      'gender': profileInfo[0],
      'birthDate': profileInfo[1],
      'phone': profileInfo[2],
      'email': profileInfo[3],
      'specialty': profileInfo[4],
      // ID is usually not editable
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
          result['birthDate'] ??
              profileInfo[1], // Ensure date format consistency
          result['phone'] ?? profileInfo[2],
          result['email'] ?? profileInfo[3],
          result['specialty'] ?? profileInfo[4],
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Persist the updated profile data
    }
  }

  // --- Helper Widget: Build Info Section (Keep as is) ---
  Widget _buildInfoSection({
    required String label,
    required List<String> details,
  }) {
    /* ... same as before ... */
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
      /* ... structure ... */
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
    /* ... same as before ... */
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
        break; // Already here
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

    // Check if profileInfo is initialized before building
    if (profileInfo.isEmpty) {
      // Show a loading indicator or placeholder while data loads
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: headerColor,
      body: Stack(
        children: [
          // --- Header (UPDATED Edit Button Action) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              color: headerColor,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 25.0,
                    right: 25.0,
                    bottom: 35,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        /* ... Profile Title ... */
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
                                onTap:
                                    _navigateToEditProfile, // <-- Call the updated navigation method
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
                        /* ... Avatar ... */
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

          // --- Content Area (Uses state variables) ---
          Positioned.fill(
            top: 165,
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
                  bottom: 90.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name (Uses state variable)
                    Text(
                      profileName, // Uses state variable
                      style: TextStyle(
                        color: effectivePrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Display Specialty below name
                    if (profileInfo.length > 4 &&
                        profileInfo[4].isNotEmpty) // Check if specialty exists
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          profileInfo[4], // Specialty from state
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

                    // ID Section (Uses state variable)
                    _buildInfoSection(label: "Doctor ID", details: [profileId]),

                    // Information Section (Uses state variable, excludes specialty if shown above)
                    _buildInfoSection(
                      label: "Contact Information",
                      details: [
                        profileInfo[0], // Gender
                        profileInfo[1], // BirthDate
                        profileInfo[2], // Phone
                        profileInfo[3], // Email
                        // Specialty is removed from here if shown under name
                      ],
                    ),

                    // --- Buttons (Keep as is, or adjust logic) ---
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      /* ... Settings Button ... */
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
                      /* ... Logout Button ... */
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
                      onPressed: () {
                        print('Log out tapped');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logout not implemented yet.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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
      // --- Bottom Navigation Bar (Keep as is) ---
      bottomNavigationBar: Container(
        /* ... Bottom nav content ... */
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
      ),
    );
  }
}
