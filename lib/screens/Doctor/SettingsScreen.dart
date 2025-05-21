// lib/screens/Doctor/SettingsScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // << Import url_launcher

import '../../main.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ... (all other state variables and methods remain the same as before)
  final int _screenIndex = 3;
  bool _weeklyReportsEnabled = false;
  bool _newPatientsEnabled = true;
  late bool _darkModeEnabled;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic'];
  String _currentDoctorName = "Loading...";
  String _currentGender = "Loading...";
  String _currentBirthDate = "Loading...";
  String _currentEmail = "Loading...";
  bool _isLoadingProfile = true;
  String? _profileErrorMessage;
  bool _isSendingPasswordReset = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _darkModeEnabled =
        context.read<ThemeNotifier>().themeMode == ThemeMode.dark;
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    // ... (keep as is)
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileErrorMessage = "User not logged in. Please log in again.";
          _currentDoctorName = "N/A";
          _currentGender = "N/A";
          _currentBirthDate = "N/A";
          _currentEmail = "N/A";
        });
      }
      return;
    }

    try {
      DocumentSnapshot doctorDoc =
          await _firestore.collection('doctors').doc(currentUser.uid).get();

      if (doctorDoc.exists && mounted) {
        Map<String, dynamic> data = doctorDoc.data() as Map<String, dynamic>;
        String birthDateStr = "N/A";
        if (data['birthDate'] != null && data['birthDate'] is Timestamp) {
          Timestamp dobTimestamp = data['birthDate'];
          birthDateStr = DateFormat('dd/MM/yyyy').format(dobTimestamp.toDate());
        } else if (data['birthDate'] is String) {
          birthDateStr = data['birthDate'];
        }

        setState(() {
          _currentDoctorName =
              data['fullName'] ??
              "${data['firstName']} ${data['lastName']}" ??
              "N/A";
          _currentGender = data['gender'] ?? "N/A";
          _currentBirthDate = birthDateStr;
          _currentEmail = data['email'] ?? currentUser.email ?? "N/A";
          _isLoadingProfile = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileErrorMessage = "Profile data not found.";
          _currentDoctorName = "N/A";
          _currentGender = "N/A";
          _currentBirthDate = "N/A";
          _currentEmail = currentUser.email ?? "N/A";
        });
      }
    } catch (e) {
      print("Error fetching doctor data for settings: $e");
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileErrorMessage = "Error loading profile: ${e.toString()}";
          _currentDoctorName = "Error";
          _currentGender = "Error";
          _currentBirthDate = "Error";
          _currentEmail = "Error";
        });
      }
    }
  }

  Future<void> _logout() async {
    // ... (keep as is)
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Log Out'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            MyApp.loginRoute,
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout error: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _navigateToEditSetting(String settingType, String currentValue) async {
    // ... (keep as is, including password reset logic)
    if (settingType == 'Password') {
      _handlePasswordReset();
    } else {
      print('Attempting to edit setting: $settingType');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Navigation to edit "$settingType" is not implemented yet.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handlePasswordReset() async {
    // ... (keep as is)
    if (_currentEmail.isEmpty ||
        _currentEmail == "N/A" ||
        _currentEmail == "Loading..." ||
        _currentEmail == "Error") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not send reset email. User email is not available.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Text(
            'A password reset link will be sent to $_currentEmail. Do you want to continue?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Send Email'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() {
        _isSendingPasswordReset = true;
      });
      try {
        await _auth.sendPasswordResetEmail(email: _currentEmail);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password reset email sent to $_currentEmail. Please check your inbox (and spam folder).',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        print("Error sending password reset email: $e");
        String message = "Failed to send password reset email.";
        if (e.code == 'user-not-found') {
          message = "No user found with this email address.";
        } else if (e.code == 'invalid-email') {
          message = "The email address is not valid.";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        print("Unexpected error sending password reset: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSendingPasswordReset = false;
          });
        }
      }
    }
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    // ... (keep as is)
    final theme = Theme.of(context);
    final effectiveColor =
        theme.textTheme.titleMedium?.color ??
        (theme.brightness == Brightness.dark
            ? Colors.white70
            : sectionTitleColor);
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

  Widget _buildAccountSettingItem(String title, {String? currentValue}) {
    // ... (keep as is)
    final theme = Theme.of(context);
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
            : itemBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final valueColor =
        theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.white.withOpacity(0.8);
    final chevronColor =
        theme.brightness == Brightness.dark ? Colors.white54 : iconColor;
    bool isProfileItem = [
      'Name',
      'Gender',
      'Birth date',
      'Email',
    ].contains(title);
    bool showLoadingIndicator = _isLoadingProfile && isProfileItem;
    bool showPasswordLoading = title == 'Password' && _isSendingPasswordReset;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: itemBg,
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          onTap:
              (showLoadingIndicator || showPasswordLoading)
                  ? null
                  : () => _navigateToEditSetting(title, currentValue ?? ''),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showLoadingIndicator || showPasswordLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                        ),
                      )
                    else if (currentValue != null)
                      Flexible(
                        child: Text(
                          currentValue,
                          style: TextStyle(color: valueColor, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    if (!(title == 'Password' && showPasswordLoading))
                      const SizedBox(width: 8),
                    if (!(title == 'Password' && showPasswordLoading))
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

  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    // ... (keep as is)
    final theme = Theme.of(context);
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
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
            ),
            Switch(
              value: value,
              onChanged: (newValue) {
                onChanged(newValue);
              },
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
              inactiveThumbColor:
                  theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[50],
              inactiveTrackColor:
                  theme.brightness == Brightness.dark
                      ? Colors.white30
                      : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdownItem() {
    // ... (keep as is)
    final theme = Theme.of(context);
    final itemBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[800]!
            : itemBackgroundColor;
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : itemTextColor;
    final dropdownBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[100]!;
    final dropdownTextColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final dropdownIconColor =
        theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.only(
          left: 15.0,
          right: 8.0,
          top: 5.0,
          bottom: 5.0,
        ),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(15.0),
        ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Language switching not implemented yet.',
                        ),
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
          ],
        ),
      ),
    );
  }

  // --- MODIFIED: Helper Widget: Call Support Button ---
  Widget _buildCallSupportButton() {
    final theme = Theme.of(context);
    final buttonBg =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.blueGrey[50]!;
    final buttonTextColor =
        theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final buttonIconColor =
        theme.iconTheme.color ??
        (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54);

    return ElevatedButton.icon(
      icon: Icon(Icons.call_outlined, size: 20, color: buttonIconColor),
      label: Text(
        'Call Emergency (911)',
        style: TextStyle(fontSize: 16, color: buttonTextColor),
      ), // Updated Label
      onPressed: () async {
        // Show confirmation dialog before calling
        final bool? confirmCall = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // User must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Emergency Call'),
              content: const Text(
                'You are about to call 911. Only proceed in a genuine emergency. Are you sure?',
                style: TextStyle(color: Colors.redAccent),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text(
                    'CALL 911',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (confirmCall == true) {
          // FOR TESTING: Use a safe number first, e.g., your own number or a test line.
          // const String phoneNumber = 'tel:YOUR_TEST_NUMBER_HERE'; // E.g., 'tel:1234567890'
          const String phoneNumber = 'tel:911'; // PRODUCTION: EMERGENCY ONLY

          final Uri phoneUri = Uri.parse(phoneNumber);

          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $phoneNumber')),
              );
            }
            print('Could not launch $phoneNumber');
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700], // Make button more prominent/warning
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        elevation: 1,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildLogoutButton() {
    // ... (keep as is)
    final theme = Theme.of(context);
    final buttonBg =
        theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.white;
    final buttonBorderColor = Colors.redAccent.withOpacity(0.5);
    final buttonTextColor = Colors.redAccent;

    return ElevatedButton.icon(
      icon: Icon(Icons.logout, color: buttonTextColor),
      label: Text(
        'Log out',
        style: TextStyle(
          color: buttonTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        foregroundColor: buttonTextColor,
        side: BorderSide(color: buttonBorderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        minimumSize: const Size(double.infinity, 50),
        elevation: 1,
      ),
    );
  }

  void _onItemTapped(int index) {
    // ... (keep as is)
    if (index == _screenIndex) return;
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyApp.doctorHomeRoute,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, MyApp.doctorPatientsRoute);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, MyApp.doctorNotesRoute);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... ( AppBar, BottomNav, and bodyContent logic - keep as is from previous answer)
    final theme = Theme.of(context);
    final currentScaffoldBg = theme.scaffoldBackgroundColor;
    final currentAppBarFgColor =
        theme.appBarTheme.foregroundColor ??
        (theme.brightness == Brightness.dark ? Colors.white : headerColor);

    Widget bodyContent;

    if (_isLoadingProfile && _profileErrorMessage == null) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_profileErrorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _profileErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade300, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDoctorData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account Settings', context),
            _buildAccountSettingItem('Name', currentValue: _currentDoctorName),
            _buildAccountSettingItem('Gender', currentValue: _currentGender),
            _buildAccountSettingItem(
              'Birth date',
              currentValue: _currentBirthDate,
            ),
            _buildAccountSettingItem('Email', currentValue: _currentEmail),
            _buildAccountSettingItem('Password'),
            _buildAccountSettingItem('Two-Factor Authentication'),

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

            _buildSectionTitle('App Preferences', context),
            _buildSwitchItem(
              'Dark Mode',
              context.watch<ThemeNotifier>().isDarkMode,
              (value) {
                context.read<ThemeNotifier>().setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
            _buildLanguageDropdownItem(),

            _buildSectionTitle('Contact Support', context),
            _buildCallSupportButton(), // This will now attempt to call 911
            const SizedBox(height: 30),

            _buildSectionTitle('Account Actions', context),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? headerColor,
        elevation: theme.appBarTheme.elevation ?? 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: currentAppBarFgColor,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                color: currentAppBarFgColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: currentScaffoldBg,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
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
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _screenIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              theme.bottomNavigationBarTheme.backgroundColor ?? bottomNavColor,
          selectedItemColor:
              theme.bottomNavigationBarTheme.selectedItemColor ??
              bottomNavSelectedColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor ??
              bottomNavUnselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: theme.bottomNavigationBarTheme.elevation ?? 5,
          selectedIconTheme:
              theme.bottomNavigationBarTheme.selectedIconTheme ??
              const IconThemeData(size: 28),
          unselectedIconTheme:
              theme.bottomNavigationBarTheme.unselectedIconTheme ??
              const IconThemeData(size: 24),
        ),
      ),
      body: bodyContent,
    );
  }
}