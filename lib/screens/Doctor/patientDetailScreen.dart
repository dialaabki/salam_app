// lib/patient_detail_screen.dart
import 'package:flutter/material.dart';
import 'patientsScreen.dart'; // Import Patient class definition

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({required this.patient, super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final int _screenIndex = 1; // Defaulting to Patients

  // --- Define LIGHT Theme Colors (Original - Unchanged) ---
  static const Color lightHeaderColor = Color(0xFF5A9AB8);
  static const Color lightHeaderTextColor = Colors.white;
  static const Color lightPrimaryContentColor = Color(0xFF003366);
  static const Color lightSecondaryContentColor = Color(0xFF5A7A9E);
  static const Color lightDividerColor = Colors.grey;
  static const Color lightNotesBackgroundColor = Color(0xFFF0F0F0);
  static const Color lightSmileyIconColor = Color(0xFFB4CC4E);
  static const Color lightBottomNavColor = Color(0xFF004A99);
  static const Color lightBottomNavSelectedColor = Colors.white;
  static const Color lightBottomNavUnselectedColor = Color(0xFFADD8E6);

  // --- Define DARK Theme Colors (ADJUSTED) ---
  static final Color darkHeaderColor = Colors.grey[850]!; // Keep header dark
  static const Color darkHeaderTextColor =
      Colors.white; // Make header text clearer
  static final Color darkPrimaryContentColor = Colors.white.withOpacity(
    0.87,
  ); // Standard bright text
  // **** ADJUSTED: Increased opacity for better visibility ****
  static final Color darkSecondaryContentColor = Colors.white.withOpacity(
    0.70,
  ); // Brighter secondary text/icons
  static final Color darkDividerColor = Colors.grey[700]!;
  // **** ADJUSTED: Slightly different shade for notes background ****
  static final Color darkNotesBackgroundColor =
      Colors.grey[850]!; // Subtle difference from pure black/grey[900] scaffold
  static final Color darkSmileyIconColor = lightSmileyIconColor.withOpacity(
    0.85,
  ); // Keep smiley visible
  static final Color darkBottomNavColor = Colors.grey[900]!;
  static final Color darkBottomNavSelectedColor =
      Colors.cyanAccent[100]!; // Adjusted selection color for pop
  static final Color darkBottomNavUnselectedColor =
      Colors.grey[600]!; // Slightly brighter unselected

  // Asset Paths (Unchanged)
  final String moodProgressPath = 'assets/images/colrdprogresspic.png';
  final String activityProgressPath = 'assets/images/numberedprogresspic.png';

  // --- Helper Widget: Build Info Section (Uses Updated Dark Colors) ---
  Widget _buildSection({
    required String title,
    required List<Widget> children,
    double topPadding = 15.0,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    // Uses the updated darkSecondaryContentColor for title
    final effectiveSecondaryColor =
        isDarkMode ? darkSecondaryContentColor : lightSecondaryContentColor;
    final effectiveDividerColor =
        isDarkMode ? darkDividerColor : lightDividerColor;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: effectiveSecondaryColor, // Now brighter in dark mode
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Divider(color: effectiveDividerColor, thickness: 0.8),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // --- Helper Widget: Build Detail Item (Uses Updated Dark Colors) ---
  Widget _buildDetailItem(String text, {IconData? icon}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final effectivePrimaryColor =
        isDarkMode ? darkPrimaryContentColor : lightPrimaryContentColor;
    // Uses the updated darkSecondaryContentColor for icon
    final effectiveSecondaryColor =
        isDarkMode ? darkSecondaryContentColor : lightSecondaryContentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            // Icon color now brighter in dark mode
            Icon(icon, color: effectiveSecondaryColor, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: effectivePrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Nav Tap Handler (Unchanged) ---
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
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/patients');
        }
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
    final Patient currentPatient = widget.patient;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Choose effective colors based on theme (using adjusted dark colors)
    final effectiveHeaderColor =
        isDarkMode ? darkHeaderColor : lightHeaderColor;
    final effectiveHeaderTextColor =
        isDarkMode ? darkHeaderTextColor : lightHeaderTextColor;
    final effectiveScaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    final effectivePrimaryContentColor =
        isDarkMode ? darkPrimaryContentColor : lightPrimaryContentColor;
    // effectiveSecondaryContentColor is handled within helpers
    final effectiveNotesBgColor =
        isDarkMode
            ? darkNotesBackgroundColor
            : lightNotesBackgroundColor; // Uses adjusted dark notes bg
    final effectiveSmileyColor =
        isDarkMode ? darkSmileyIconColor : lightSmileyIconColor;
    final effectiveBottomNavColor =
        isDarkMode ? darkBottomNavColor : lightBottomNavColor;
    final effectiveBottomNavSelectedColor =
        isDarkMode ? darkBottomNavSelectedColor : lightBottomNavSelectedColor;
    final effectiveBottomNavUnselectedColor =
        isDarkMode
            ? darkBottomNavUnselectedColor
            : lightBottomNavUnselectedColor;
    // Avatar dimming logic remains the same
    final effectiveAvatarBg =
        isDarkMode
            ? currentPatient.avatarBgColor.withOpacity(0.7)
            : currentPatient.avatarBgColor;

    return Scaffold(
      backgroundColor: effectiveHeaderColor,
      appBar: AppBar(
        backgroundColor: effectiveHeaderColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: effectiveHeaderTextColor,
          ), // Uses adjusted dark header text
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          currentPatient.name,
          style: TextStyle(
            color: effectiveHeaderTextColor,
            fontSize: 20,
          ), // Uses adjusted dark header text
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- Header Content (Below AppBar - Unchanged structurally) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Container(
              color: effectiveHeaderColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,
                  bottom: 45,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        currentPatient.name,
                        style: TextStyle(
                          color:
                              effectiveHeaderTextColor, // Uses adjusted dark header text
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 15),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          effectiveAvatarBg, // Theme-aware (dimmed dark)
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(currentPatient.avatarPath),
                        backgroundColor: Colors.transparent,
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Content Area ---
          Positioned.fill(
            top: 95,
            child: Container(
              decoration: BoxDecoration(
                color:
                    effectiveScaffoldBackgroundColor, // Standard theme scaffold
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 25.0,
                  right: 25.0,
                  bottom: 90.0, // Added bottom padding for nav bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Information Section (Uses updated helper) ---
                    _buildSection(
                      title: "Information",
                      children: [
                        _buildDetailItem("${currentPatient.age} years"),
                        _buildDetailItem("079-xxx-xxxx"),
                        _buildDetailItem(
                          "morad@gmail.com",
                          icon: Icons.email_outlined,
                        ), // Icon uses updated color
                        _buildDetailItem(currentPatient.condition),
                      ],
                    ),

                    // --- Progress Section (Uses updated helper) ---
                    _buildSection(
                      title: "Progress",
                      children: [
                        Row(
                          // ... structure unchanged ...
                          children: [
                            Expanded(
                              child: Text(
                                "MOOD Tracking Average\nfor this week",
                                style: TextStyle(
                                  color:
                                      effectivePrimaryContentColor, // Main text color
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Image.asset(
                                  moodProgressPath,
                                  height: 50,
                                  // Error icon color adapts
                                  errorBuilder:
                                      (c, e, s) => Icon(
                                        Icons.error,
                                        color:
                                            isDarkMode
                                                ? Colors.white54
                                                : Colors.grey,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  Icons.sentiment_satisfied_alt,
                                  color:
                                      effectiveSmileyColor, // Uses adjusted dark color
                                  size: 35,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          // ... structure unchanged ...
                          children: [
                            Expanded(
                              child: Text(
                                "Activities progress\nfor this week",
                                style: TextStyle(
                                  color:
                                      effectivePrimaryContentColor, // Main text color
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              activityProgressPath,
                              height: 80,
                              errorBuilder:
                                  (c, e, s) => Icon(
                                    Icons.error,
                                    color:
                                        isDarkMode
                                            ? Colors.white54
                                            : Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // --- Notes Section (Uses updated helper and colors) ---
                    _buildSection(
                      title: "Notes", // Title uses updated secondary color
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                effectiveNotesBgColor, // Uses adjusted dark notes bg
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey.shade300, // Border adapts
                            ),
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            initialValue:
                                "Patient seems responsive to treatment...",
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                              color: effectivePrimaryContentColor,
                            ), // Bright text for input
                            decoration: InputDecoration(
                              hintText: "Add notes here...",
                              // Hint text uses updated secondary color (brighter)
                              hintStyle: TextStyle(
                                color:
                                    isDarkMode
                                        ? darkSecondaryContentColor
                                        : Colors.grey[600],
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Keep bottom padding
                    const SizedBox(
                      height: 20,
                    ), // Adjusted slightly from 80, use main padding + nav height
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // --- Bottom Navigation Bar (Using adjusted dark colors) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey[700]! : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Patients',
            ), // Selected
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _screenIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: effectiveBottomNavColor, // Uses adjusted dark color
          selectedItemColor:
              effectiveBottomNavSelectedColor, // Uses adjusted dark color
          unselectedItemColor:
              effectiveBottomNavUnselectedColor, // Uses adjusted dark color
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          elevation: 5,
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 24),
        ),
      ),
    );
  }
}