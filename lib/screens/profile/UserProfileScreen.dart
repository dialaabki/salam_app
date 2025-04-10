import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav_bar.dart'; // Use original nav bar
import '../../../main.dart'; // For theme colors if needed (or define locally)

// --- Define Colors (or import from main/theme file) ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white;
const Color separatorColor = Colors.black26;

// --- Asset Paths ---
const String profileAvatarPlaceholder = "assets/images/profile_avatar_placeholder.png"; // ** REPLACE **

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth * 0.15; // Adjust size

    return Scaffold(
      backgroundColor: mainAppColor, // Background behind the white card
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: mainAppColor, // AppBar blends with top background
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: () {
              // TODO: Implement edit profile navigation/action
              print("Edit profile tapped");
            },
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white), // Back button if navigated to
      ),
      bottomNavigationBar: const AppBottomNavBar(), // Use original nav bar name
      body: Stack( // Use Stack for overlapping avatar
        children: [
          // --- White Content Container (starts below AppBar) ---
          Padding(
            // Add padding to push the white container below the avatar center
            padding: EdgeInsets.only(top: avatarRadius),
            child: Container(
              height: double.infinity, // Take remaining height
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
                    top: avatarRadius + 20.0, // Space for avatar + extra padding
                    left: 25.0,
                    right: 25.0,
                    bottom: 25.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- User Info ---
                      _buildInfoSectionTitle("Name"),
                      _buildInfoDetail("Name name"), // Placeholder Data
                      const SizedBox(height: 15),

                      _buildInfoSectionTitle("ID"),
                      _buildInfoDetail("#123"), // Placeholder Data
                      const SizedBox(height: 15),

                      _buildInfoSectionTitle("Information"),
                      _buildInfoDetail("Male"), // Placeholder Data
                      _buildInfoDetail("07/11/1980"), // Placeholder Data
                      _buildInfoDetail("079-xxx-xxxx"), // Placeholder Data
                      _buildInfoDetail("name@gmail.com"), // Placeholder Data
                      const SizedBox(height: 15),

                      _buildInfoSectionTitle("Progress shared with"),
                      _buildInfoDetail("Dr name"), // Placeholder Data
                      const SizedBox(height: 30), // Add some bottom spacing
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Circular Avatar (Positioned at the top) ---
          Positioned(
            top: 0, // Align to the top edge of the Stack (below AppBar)
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey[300], // Placeholder background
                // TODO: Replace with actual image loading
                backgroundImage: AssetImage(profileAvatarPlaceholder),
                 onBackgroundImageError: (e, s) { // Handle image load errors
                   print("Failed to load profile image: $e");
                 },
                child: ClipOval( // Ensure image is clipped if using child Image.asset
                   // child: Image.asset(profileAvatarPlaceholder, fit: BoxFit.cover) // Alternative if backgroundImage fails
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: lightTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoDetail(String detail) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail,
            style: TextStyle(
              color: darkTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: separatorColor, thickness: 0.8),
        ],
      ),
    );
  }
}