// lib/settings_screen.dart
import 'package:flutter/material.dart';
// Import your main file or wherever the theme notifier is defined
import '/main.dart'; // Assuming themeNotifier is accessible via main.dart
// Import edit screens if/when you create them
// import 'edit_setting_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart'; // Adjust path if needed


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Screen Index for Bottom Nav ---
  final int _screenIndex = 3; // Highlight Profile as parent section

  // State variables
  bool _weeklyReportsEnabled = false;
  bool _newPatientsEnabled = true;
  late bool _darkModeEnabled;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic'];

  // Example State for display (load real data in initState)
  String _currentDoctorName = "Dr. Evelyn Reed";
  String _currentGender = "Female";
  String _currentBirthDate = "11/07/1980";
  String _currentEmail = "e.reed.clinic@mail.com";
  bool _twoFactorEnabled = false; // Example state

  // Color constants
  static const Color headerColor = Color(0xFF5A9AB8);
  static const Color itemBackgroundColor = Color(0xFF3A7D99);
  static const Color sectionTitleColor = Color(0xFF3A7D99);
  static const Color itemTextColor = Colors.white;
  static const Color iconColor = Colors.white;
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = themeNotifier.value == ThemeMode.dark;
    // TODO: Load actual settings data here from persistence/API
  }

  // --- Helper: Navigate to Edit (Shows Placeholder) ---
  void _navigateToEditSetting(String settingType, String currentValue) async {
    print('Attempting to edit setting: $settingType'); // Debug print

    // --- Placeholder Action ---
    // In a real app, you would navigate to a specific screen:
    // e.g., if (settingType == 'Name') {
    //         Navigator.push(context, MaterialPageRoute(builder: (_) => EditNameScreen(currentName: currentValue)));
    //      } else if (settingType == 'Password') {
    //         Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
    //      }
    // For now, just show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigation to edit "$settingType" is not implemented yet.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    // --- End Placeholder ---
  }

  // --- Helper Widget: Section Title ---
  Widget _buildSectionTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : sectionTitleColor;
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

  // --- Helper Widget: Account Setting Item (Calls _navigateToEditSetting) ---
  Widget _buildAccountSettingItem(String title, {String? currentValue}) {
    final theme = Theme.of(context);
    // Use theme colors for better adaptability
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : itemBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final valueColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.white.withOpacity(0.8);
    final chevronColor =
        theme.brightness == Brightness.dark ? Colors.white54 : iconColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: itemBg,
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          // --- Calls the navigation/placeholder function ---
          onTap: () => _navigateToEditSetting(title, currentValue ?? ''),
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 15.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16)),
                Row(
                  mainAxisSize: MainAxisSize.min, // Keep row compact
                  children: [
                    if (currentValue != null)
                      Flexible(
                        // Prevent long values overflowing
                        child: Text(
                          currentValue,
                          style: TextStyle(color: valueColor, fontSize: 15),
                          overflow:
                              TextOverflow.ellipsis, // Add ellipsis if too long
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
  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : itemBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ), // Expanded title
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor:
                  Colors.grey[700]?.withOpacity(0.3) ??
                  Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Language Dropdown Item ---
  Widget _buildLanguageDropdownItem() {
    final theme = Theme.of(context);
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : itemBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final dropdownBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.white.withOpacity(0.9);
    final dropdownTextColor =
        theme.brightness == Brightness.dark
            ? Colors.white
            : itemBackgroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Language", style: TextStyle(color: textColor, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: dropdownBg,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: dropdownTextColor,
                  ),
                  dropdownColor: dropdownBg,
                  style: TextStyle(color: dropdownTextColor, fontSize: 16),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedLanguage = newValue);
                      print('Language changed to: $newValue');
                      // TODO: Implement actual language change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Language switching not implemented yet.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  items:
                      _languages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
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
    final buttonBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : itemBackgroundColor;
    final buttonTextColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;

    return ElevatedButton.icon(
      icon: Icon(Icons.call_outlined, size: 20, color: buttonTextColor),
      label: Text(
        'Call app support',
        style: TextStyle(fontSize: 16, color: buttonTextColor),
      ),
      onPressed: () {
        print('Call app support tapped');
        // TODO: Implement call functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call support not implemented yet.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        elevation: 2,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  // --- Helper Widget: Log Out Button ---
  Widget _buildLogoutButton() {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text(
        'Log out',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: () {
        print('Log out tapped');
        // TODO: Implement logout logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout not implemented yet.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.cardColor,
        side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size(double.infinity, 50),
        elevation: 1,
      ),
    );
  }

  // --- Bottom Nav Tap Handler ---
  void _onItemTapped(int index) {
    if (index == _screenIndex && Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patients');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notes');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings_outlined, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20.0,
          20.0,
          20.0,
          90.0,
        ), // Padding bottom for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Settings ---
            _buildSectionTitle('Account Settings', context),
            _buildAccountSettingItem('Name', currentValue: _currentDoctorName),
            _buildAccountSettingItem('Gender', currentValue: _currentGender),
            _buildAccountSettingItem(
              'Birth date',
              currentValue: _currentBirthDate,
            ),
            _buildAccountSettingItem('Email', currentValue: _currentEmail),
            _buildAccountSettingItem('Password'), // Navigates elsewhere usually
            _buildAccountSettingItem(
              'Two-Factor Authentication',
            ), // Navigates elsewhere
            // --- Notification Preferences ---
            _buildSectionTitle('Notification Preferences', context),
            _buildSwitchItem(
              'Weekly progress reports summary',
              _weeklyReportsEnabled,
              (value) => setState(() => _weeklyReportsEnabled = value),
            ),
            _buildSwitchItem(
              'New patient assigned alerts',
              _newPatientsEnabled,
              (value) => setState(() => _newPatientsEnabled = value),
            ),

            // --- App Preferences ---
            _buildSectionTitle('App Preferences', context),
            _buildSwitchItem('Dark Mode', _darkModeEnabled, (value) {
              setState(() => _darkModeEnabled = value);
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            }),
            _buildLanguageDropdownItem(),

            // --- Contact Support ---
            _buildSectionTitle('Contact Support', context),
            _buildCallSupportButton(),
            const SizedBox(height: 30),

            // --- Log Out ---
            _buildSectionTitle('Account Actions', context),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ), // Selected
          ],
          currentIndex: _screenIndex, // Highlight Profile
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
