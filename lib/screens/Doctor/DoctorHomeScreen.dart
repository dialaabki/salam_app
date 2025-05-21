import 'package:flutter/material.dart';
import 'appDrawer.dart'; // <-- Import the drawer
import 'patientsScreen.dart'; // <-- Import PatientsScreen to access Patient class and potentially the screen itself
import 'patientDetailScreen.dart'; // <-- Import detail screen
import 'NotesScreen.dart'; // <-- *** ADDED: Import Notes Screen ***
import 'ProfileScreen.dart'; // <-- *** ADDED: Import Profile Screen ***

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  // Define the route name for this screen for consistency (optional but good practice)
  static const routeName = '/home'; // Or '/' if it's the initial route

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  // This index should reflect the index of THIS screen in the bottom nav bar
  final int _screenIndex = 0; // 0 for Home

  final String doctorImagePath = 'assets/images/doctorpic.png';
  final String malePatientImagePath = 'assets/images/malepatientpic.png';
  final String femalePatientImagePath = 'assets/images/femalepatientpic.png';
  final String chartImagePath = 'assets/images/chartpic.png';

  final List<Patient> _recentPatients = [
    Patient(
      id: '5',
      name: 'Ahmad',
      age: '29',
      condition: 'Depression',
      avatarPath: 'assets/images/malepatientpic.png',
      avatarBgColor: const Color(0xFFA5D6F0),
    ),
    Patient(
      id: '6',
      name: 'Sara',
      age: '20',
      condition: 'Anxiety',
      avatarPath: 'assets/images/femalepatientpic.png',
      avatarBgColor: const Color(0xFFD1C4E9),
    ),
    Patient(
      id: '7',
      name: 'Omar',
      age: '18',
      condition: 'ADHD',
      avatarPath: 'assets/images/malepatientpic.png',
      avatarBgColor: const Color(0xFFA5D6F0),
    ),
    Patient(
      id: '8',
      name: 'Mohammed',
      age: '27',
      condition: 'OCD',
      avatarPath: 'assets/images/malepatientpic.png',
      avatarBgColor: const Color(0xFFA5D6F0),
    ),
  ];

  // --- Helper Method to Build Patient Cards (Modified for Tap & Dark Theme) ---
  Widget _buildPatientCard({
    required Patient patient,
    required Color lightBackgroundColor,
    required Color lightAvatarBackgroundColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define Dark Theme Colors for Card
    final Color darkCardBg = Colors.grey[800]!;
    final Color darkAvatarBg = patient.avatarBgColor.withOpacity(
      0.6,
    ); // Dim avatar bg slightly
    final Color darkPrimaryText = Colors.white70;
    final Color darkSecondaryText = Colors.white54;

    // Define Light Theme Colors for Card
    final Color lightPrimaryText = const Color(0xFF4A4A6A);
    final Color lightSecondaryText = Colors.grey[600]!;

    // Choose colors based on theme
    final Color effectiveCardBg =
        isDarkMode ? darkCardBg : lightBackgroundColor;
    final Color effectiveAvatarBg =
        isDarkMode ? darkAvatarBg : lightAvatarBackgroundColor;
    final Color effectivePrimaryTextColor =
        isDarkMode ? darkPrimaryText : lightPrimaryText;
    final Color effectiveSecondaryTextColor =
        isDarkMode ? darkSecondaryText : lightSecondaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patient: patient),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveCardBg,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isDarkMode ? 0.3 : 0.1,
                ), // Adjusted shadow
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: effectiveAvatarBg,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(patient.avatarPath),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: effectivePrimaryTextColor,
                        ),
                      ),
                      Text(
                        "${patient.age} Years\n${patient.condition}",
                        style: TextStyle(
                          fontSize: 14,
                          color: effectiveSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Keep chart image as is, or use a theme-specific version if available
                Image.asset(chartImagePath, height: 50, width: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Navigation Logic ---
  void _onItemTapped(int index) {
    // If the tapped index is the same as the current screen's index, do nothing
    if (index == _screenIndex) return;

    // Navigate based on the tapped index
    switch (index) {
      case 0:
        // Already on Home screen, pushReplacementNamed would still work but is redundant
        // Navigator.pushReplacementNamed(context, DoctorHomeScreen.routeName); // or '/home'
        break; // Do nothing as we are already here
      case 1:
        // Navigate to Patients Screen using its defined named route
        Navigator.pushReplacementNamed(
          context,
          '/patients',
        ); // Assumes '/patients' is defined in MaterialApp
        break;
      case 2:
        // Navigate to Notes Screen using its defined named route
        Navigator.pushReplacementNamed(
          context,
          '/notes',
        ); // Assumes '/notes' is defined in MaterialApp
        break;
      case 3:
        // Navigate to Profile Screen using its defined named route
        Navigator.pushReplacementNamed(
          context,
          '/profile',
        ); // Assumes '/profile' is defined in MaterialApp
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Define Light Theme Colors ---
    const Color lightPrimaryTextColor = Color(0xFF003366);
    const Color lightSecondaryTextColor = Color(0xFF5A7A9E);
    const Color lightAppBarBg = Colors.white;
    const Color lightScaffoldBg = Colors.white;
    const Color lightBottomNavColor = Color(0xFF004A99);
    const Color lightBottomNavSelectedColor = Colors.white;
    const Color lightBottomNavUnselectedColor = Color(0xFFADD8E6);
    const Color lightBlueCardBg = Color(0xFFE0F2F7);
    const Color lightBlueAvatarBg = Color(0xFFB3E5FC);
    const Color lightPurpleCardBg = Color(0xFFEDE7F6);
    const Color lightPurpleAvatarBg = Color(0xFFD1C4E9);

    // --- Define Dark Theme Colors ---
    final Color darkPrimaryTextColor = Colors.white.withOpacity(0.87);
    final Color darkSecondaryTextColor = Colors.white.withOpacity(0.60);
    final Color darkAppBarBg = Colors.grey[900]!;
    final Color darkScaffoldBg = const Color(0xFF121212);
    final Color darkBottomNavColor = Colors.grey[900]!;
    final Color darkBottomNavSelectedColor = Colors.tealAccent[100]!;
    final Color darkBottomNavUnselectedColor = Colors.grey[500]!;

    // --- Choose Colors Based on Theme ---
    final Color effectivePrimaryTextColor =
        isDarkMode ? darkPrimaryTextColor : lightPrimaryTextColor;
    final Color effectiveSecondaryTextColor =
        isDarkMode ? darkSecondaryTextColor : lightSecondaryTextColor;
    final Color effectiveAppBarBg = isDarkMode ? darkAppBarBg : lightAppBarBg;
    final Color effectiveScaffoldBg =
        isDarkMode ? darkScaffoldBg : lightScaffoldBg;
    final Color effectiveBottomNavColor =
        isDarkMode ? darkBottomNavColor : lightBottomNavColor;
    final Color effectiveBottomNavSelectedColor =
        isDarkMode ? darkBottomNavSelectedColor : lightBottomNavSelectedColor;
    final Color effectiveBottomNavUnselectedColor =
        isDarkMode
            ? darkBottomNavUnselectedColor
            : lightBottomNavUnselectedColor;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: effectiveScaffoldBg,
      appBar: AppBar(
        backgroundColor: effectiveAppBarBg,
        elevation: 0,
        title: Text(
          'Hello Dr.Name 👋', // Replace with actual doctor name if available
          style: TextStyle(
            color: effectiveSecondaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: effectivePrimaryTextColor, size: 30),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 10),
        ],
        automaticallyImplyLeading: false,
      ),

      endDrawer: const AppDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10.0),
              child: Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: effectivePrimaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(doctorImagePath),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Recent Patients Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: effectivePrimaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Column(
              children:
                  _recentPatients.map((patient) {
                    // Determine color based on index for alternating style
                    bool isBlueTheme =
                        _recentPatients.indexOf(patient) % 2 == 0;
                    return _buildPatientCard(
                      patient: patient,
                      // Pass light theme colors; the function handles dark mode logic
                      lightBackgroundColor:
                          isBlueTheme ? lightBlueCardBg : lightPurpleCardBg,
                      lightAvatarBackgroundColor:
                          isBlueTheme ? lightBlueAvatarBg : lightPurpleAvatarBg,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20), // Add some padding at the bottom
          ],
        ),
      ),

      // --- Bottom Navigation Bar (Uses _onItemTapped for navigation) ---
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home', // Index 0
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: 'Patients', // Index 1
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Notes', // Index 2
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile', // Index 3
            ),
          ],
          currentIndex: _screenIndex, // Highlights the 'Home' icon
          onTap: _onItemTapped, // Calls the navigation function
          type: BottomNavigationBarType.fixed,
          backgroundColor: effectiveBottomNavColor,
          selectedItemColor: effectiveBottomNavSelectedColor,
          unselectedItemColor: effectiveBottomNavUnselectedColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          elevation: 5,
        ),
      ),
    );
  }
}