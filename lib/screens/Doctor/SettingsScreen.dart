// lib/settings_screen.dart (Assuming this is for the Doctor)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// --- Ensure these paths are correct for your project structure ---
// Import main.dart for route constants like MyApp.loginRoute and MyApp.doctorHomeRoute
import '../../main.dart';
// Import your ThemeNotifier provider
import '../../providers/theme_provider.dart'; // Adjust path if needed
// Import login screen directly only if NOT using named routes for navigation
// import '../auth/loginScreen.dart';
// Import edit screens if/when you create them
// import 'edit_setting_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Screen Index for THIS screen's Bottom Nav ---
  // Index 3 corresponds to the Settings/Profile icon in the custom bar below
  final int _screenIndex = 3;

  // State variables for settings toggles/values
  bool _weeklyReportsEnabled = false;
  bool _newPatientsEnabled = true; // Example initial value
  late bool _darkModeEnabled; // Initialized in initState
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic'];

  // Example State for display placeholders (replace with actual data loading)
  String _currentDoctorName = "Dr. Evelyn Reed"; // TODO: Load actual data
  String _currentGender = "Female"; // TODO: Load actual data
  String _currentBirthDate = "11/07/1980"; // TODO: Load actual data
  String _currentEmail = "e.reed.clinic@mail.com"; // TODO: Load actual data
  // bool _twoFactorEnabled = false; // Example state for 2FA if needed

  // Color constants (Consider moving to a dedicated theme/constants file)
  static const Color headerColor = Color(0xFF5A9AB8); // Example header color
  static const Color itemBackgroundColor = Color(0xFF3A7D99); // Background for setting items
  static const Color sectionTitleColor = Color(0xFF3A7D99); // Color for section titles in light mode
  static const Color itemTextColor = Colors.white; // Text inside setting items
  static const Color iconColor = Colors.white; // Icons inside setting items
  // Specific colors for THIS screen's bottom nav bar
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);


  @override
  void initState() {
    super.initState();
    // Initialize dark mode state based on the provider when the screen loads
    _darkModeEnabled = context.read<ThemeNotifier>().themeMode == ThemeMode.dark;
    // TODO: Load actual doctor profile and settings data here from Firestore/API
    // Fetch data associated with FirebaseAuth.instance.currentUser?.uid
    // _loadDoctorData(); // Example function call
  }

  /* Example data loading function (implement details later)
  Future<void> _loadDoctorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch data from Firestore based on user.uid
      // DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('doctors').doc(user.uid).get();
      // if (docSnap.exists && mounted) {
      //   setState(() {
      //     _currentDoctorName = docSnap.get('fullName') ?? 'N/A';
      //     _currentEmail = docSnap.get('email') ?? 'N/A';
      //     // ... load other fields ...
      //   });
      // }
      // Load settings preferences if stored separately
    }
  }
  */


  // --- LOGOUT FUNCTION ---
  Future<void> _logout() async {
    // Add a loading indicator if desired
    // setState(() => _isLoggingOut = true);
    try {
      // Show confirmation dialog
      final bool? confirmLogout = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // User must tap button
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false), // Return false
              ),
              TextButton(
                child: const Text('Log Out'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true), // Return true
              ),
            ],
          );
        },
      );

      // Proceed only if user confirmed
      if (confirmLogout == true) {
        await FirebaseAuth.instance.signOut();
        // Check if the widget is still mounted before navigating
        if (mounted) {
          // Navigate to Login Screen and remove all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            MyApp.loginRoute, // Use the constant defined in MyApp (main.dart)
            (Route<dynamic> route) => false, // Remove all routes below
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Error during logout: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("An unexpected error occurred during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred during logout.'), backgroundColor: Colors.red),
        );
      }
    } finally {
       // If using a loading indicator, stop it here
       // if (mounted) setState(() => _isLoggingOut = false);
    }
  }
  // --- END LOGOUT FUNCTION ---

  // --- Helper: Navigate to Edit Setting (Shows Placeholder) ---
  void _navigateToEditSetting(String settingType, String currentValue) async {
    print('Attempting to edit setting: $settingType');
    // Placeholder Action: Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation to edit "$settingType" is not implemented yet.'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Implement actual navigation to specific edit screens based on settingType
    // e.g., Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileFieldScreen(field: settingType, initialValue: currentValue)));
  }

  // --- Helper Widget: Section Title ---
  Widget _buildSectionTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    // Use theme's text color, fallback to specific color if needed
    final effectiveColor = theme.textTheme.titleMedium?.color ??
                           (theme.brightness == Brightness.dark ? Colors.white70 : sectionTitleColor);
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
          color: effectiveColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // --- Helper Widget: Account Setting Item ---
  Widget _buildAccountSettingItem(String title, {String? currentValue}) {
    final theme = Theme.of(context);
    // Use theme colors for better adaptability or fallbacks
    final itemBg = theme.brightness == Brightness.dark ? Colors.grey[800]! : itemBackgroundColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final valueColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.white.withOpacity(0.8);
    final chevronColor = theme.brightness == Brightness.dark ? Colors.white54 : iconColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: itemBg,
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          onTap: () => _navigateToEditSetting(title, currentValue ?? ''),
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentValue != null)
                      Flexible(
                        child: Text(
                          currentValue,
                          style: TextStyle(color: valueColor, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: chevronColor, size: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Switch Item ---
  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    final itemBg = theme.brightness == Brightness.dark ? Colors.grey[800]! : itemBackgroundColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : itemTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: itemBg, borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
              inactiveThumbColor: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[50],
              inactiveTrackColor: theme.brightness == Brightness.dark ? Colors.white30 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Language Dropdown Item ---
  Widget _buildLanguageDropdownItem() {
    final theme = Theme.of(context);
    final itemBg = theme.brightness == Brightness.dark ? Colors.grey[800]! : itemBackgroundColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final dropdownBg = theme.brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!;
    final dropdownTextColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final dropdownIconColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.only(left: 15.0, right: 8.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(color: itemBg, borderRadius: BorderRadius.circular(15.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Language", style: TextStyle(color: textColor, fontSize: 16)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                icon: Icon(Icons.keyboard_arrow_down, color: dropdownIconColor),
                dropdownColor: dropdownBg,
                style: TextStyle(color: dropdownTextColor, fontSize: 16),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedLanguage = newValue);
                    print('Language changed to: $newValue');
                    // TODO: Implement actual language change using localization package
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language switching not implemented yet.'), duration: Duration(seconds: 2)),
                    );
                  }
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Call Support Button ---
  Widget _buildCallSupportButton() {
    final theme = Theme.of(context);
    final buttonBg = theme.brightness == Brightness.dark ? Colors.grey[700]! : Colors.blueGrey[50]!;
    final buttonTextColor = theme.textTheme.bodyLarge?.color ?? (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final buttonIconColor = theme.iconTheme.color ?? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    return ElevatedButton.icon(
      icon: Icon(Icons.call_outlined, size: 20, color: buttonIconColor),
      label: Text('Call app support', style: TextStyle(fontSize: 16, color: buttonTextColor)),
      onPressed: () {
        print('Call app support tapped');
        // TODO: Implement call functionality (e.g., using url_launcher package to dial a number)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call support not implemented yet.'), duration: Duration(seconds: 2)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        foregroundColor: buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        elevation: 1,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  // --- Helper Widget: Log Out Button ---
  Widget _buildLogoutButton() {
    final theme = Theme.of(context);
    final buttonBg = theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.white;
    final buttonBorderColor = Colors.redAccent.withOpacity(0.5);
    final buttonTextColor = Colors.redAccent;

    return ElevatedButton.icon(
      icon: Icon(Icons.logout, color: buttonTextColor),
      label: Text(
        'Log out',
        style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      // --- USE THE LOGOUT FUNCTION ---
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        foregroundColor: buttonTextColor,
        side: BorderSide(color: buttonBorderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size(double.infinity, 50),
        elevation: 1,
      ),
    );
  }

  // --- Bottom Nav Tap Handler (For THIS screen's custom bar) ---
  void _onItemTapped(int index) {
    // Prevent navigation if already on the target screen index
    if (index == _screenIndex) return;

    // Use named routes defined in main.dart
    // Ensure these routes exist and point to the correct Doctor screens
    switch (index) {
      case 0: // Home
        // Navigate and remove history IF coming from a different tab
        Navigator.pushNamedAndRemoveUntil(context, MyApp.doctorHomeRoute, (route) => false);
        break;
      case 1: // Patients
        Navigator.pushReplacementNamed(context, '/doctor_patients'); // Replace with your actual patients route name
        break;
      case 2: // Notes
        Navigator.pushReplacementNamed(context, '/doctor_notes'); // Replace with your actual notes route name
        break;
      case 3: // Settings (This screen) - Do nothing as we are already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentScaffoldBg = theme.scaffoldBackgroundColor;
    final currentAppBarFgColor = theme.appBarTheme.foregroundColor ?? (theme.brightness == Brightness.dark ? Colors.white : headerColor);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? headerColor,
        elevation: theme.appBarTheme.elevation ?? 0,
        automaticallyImplyLeading: false, // Remove back arrow if this is a main tab
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: currentAppBarFgColor, size: 28),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                color: currentAppBarFgColor, fontSize: 22, fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: currentScaffoldBg,

      // --- USE CUSTOM BOTTOM NAV BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)), // Use theme divider color
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'), // Updated icon
          ],
          currentIndex: _screenIndex, // Highlight Settings (index 3)
          onTap: _onItemTapped, // Use the handler defined above
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? bottomNavColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? bottomNavSelectedColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? bottomNavUnselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 1,
          unselectedFontSize: 1,
          elevation: theme.bottomNavigationBarTheme.elevation ?? 5,
          selectedIconTheme: theme.bottomNavigationBarTheme.selectedIconTheme ?? const IconThemeData(size: 28),
          unselectedIconTheme: theme.bottomNavigationBarTheme.unselectedIconTheme ?? const IconThemeData(size: 24),
        ),
      ),
      // --- END CUSTOM BOTTOM NAV BAR ---

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0), // Bottom padding reduced
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Settings ---
            _buildSectionTitle('Account Settings', context),
            _buildAccountSettingItem('Name', currentValue: _currentDoctorName),
            _buildAccountSettingItem('Gender', currentValue: _currentGender),
            _buildAccountSettingItem('Birth date', currentValue: _currentBirthDate),
            _buildAccountSettingItem('Email', currentValue: _currentEmail),
            _buildAccountSettingItem('Password'), // No current value shown
            _buildAccountSettingItem('Two-Factor Authentication'), // No current value shown

            // --- Notification Preferences ---
            _buildSectionTitle('Notification Preferences', context),
            _buildSwitchItem('Weekly progress reports summary', _weeklyReportsEnabled, (value) => setState(() => _weeklyReportsEnabled = value)),
            _buildSwitchItem('New patient assigned alerts', _newPatientsEnabled, (value) => setState(() => _newPatientsEnabled = value)),

            // --- App Preferences ---
            _buildSectionTitle('App Preferences', context),
            _buildSwitchItem('Dark Mode', context.watch<ThemeNotifier>().isDarkMode, (value) {
              context.read<ThemeNotifier>().setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            }),
            _buildLanguageDropdownItem(),

            // --- Contact Support ---
            _buildSectionTitle('Contact Support', context),
            _buildCallSupportButton(),
            const SizedBox(height: 30),

            // --- Log Out ---
            _buildSectionTitle('Account Actions', context),
            _buildLogoutButton(), // Button calls _logout
            const SizedBox(height: 20), // Final padding
          ],
        ),
      ),
    );
  }
}