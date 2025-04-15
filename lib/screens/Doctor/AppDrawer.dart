// lib/app_drawer.dart
import 'package:flutter/material.dart';

// Import the screens this drawer navigates to
import 'notificationsScreen.dart';
import 'notesScreen.dart';
import 'settingsScreen.dart';
import 'profileScreen.dart';
import 'patientsScreen.dart'; // <-- ***** 1. ADD THIS IMPORT *****

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Color constants (ensure consistency)
  final Color primaryTextColor = const Color(0xFF003366);
  final Color drawerItemColor = const Color(0xFFE0F2F7);
  final Color iconColor = const Color(0xFF5A7A9E);

  // Helper method to build individual drawer items
  Widget _buildDrawerItem({
    required String title,
    IconData? icon,
    String? imagePath,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    Widget leadingWidget;
    if (imagePath != null) {
      leadingWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.5),
        child: Image.asset(imagePath, height: 24, width: 24),
      );
    } else if (icon != null) {
      leadingWidget = Icon(icon, color: iconColor, size: 24);
    } else {
      leadingWidget = const SizedBox(width: 35, height: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
      child: Material(
        color: drawerItemColor,
        borderRadius: BorderRadius.circular(30.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                leadingWidget,
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Path for the custom patients icon - VERIFY THIS PATH IS STILL CORRECT
    const String patientsIconPath = 'assets/images/patientmenupic.png';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Drawer Header ---
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 25.0, bottom: 20.0),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ),

          // --- Drawer Items ---

          // ***** 2. UPDATE onTap FOR PATIENTS ITEM *****
          _buildDrawerItem(
            context: context,
            imagePath: patientsIconPath, // Use the specific icon for Patients
            title: 'Patients',
            onTap: () {
              // print('Patients tapped'); // Optional debug print
              Navigator.pop(context); // Close the drawer

              // Navigate to PatientsScreen, replacing the current screen
              // This prevents building up a back stack from the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PatientsScreen()),
              );
              // If you want to allow going back from PatientsScreen to the previous screen:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientsScreen()));
            },
          ),

          // *********************************************
          _buildDrawerItem(
            context: context,
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.assignment_outlined,
            title: 'Notes',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
