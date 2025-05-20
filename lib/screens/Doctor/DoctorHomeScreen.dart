import 'package:flutter/material.dart';
import 'appDrawer.dart'; // <-- Import the drawer (Assuming this exists)
import 'patientsScreen.dart'; // <-- Import to access Patient class
import 'patientDetailScreen.dart'; // <-- Import detail screen

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final int _screenIndex = 0; // This is the Home screen

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

  void _onItemTapped(int index) {
    if (index == _screenIndex) return;
    switch (index) {
      case 0:
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
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Define Light Theme Colors ---
    const Color lightPrimaryTextColor = Color(0xFF003366);
    const Color lightSecondaryTextColor = Color(0xFF5A7A9E);
    const Color lightAppBarBg = Colors.white;
    const Color lightScaffoldBg =
        Colors.white; // Default scaffold is usually white
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
    final Color darkScaffoldBg = const Color(0xFF121212); // Common dark bg
    final Color darkBottomNavColor = Colors.grey[900]!;
    final Color darkBottomNavSelectedColor =
        Colors.tealAccent[100]!; // Brighter selected color
    final Color darkBottomNavUnselectedColor = Colors.grey[500]!;
    // Card colors are handled inside _buildPatientCard

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
      backgroundColor:
          effectiveScaffoldBg, // Apply theme-based scaffold background
      appBar: AppBar(
        backgroundColor:
            effectiveAppBarBg, // Apply theme-based AppBar background
        elevation: 0,
        title: Text(
          'Hello Dr.Name 👋',
          style: TextStyle(
            color:
                effectiveSecondaryTextColor, // Use theme-based secondary text color
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: effectivePrimaryTextColor,
              size: 30,
            ), // Use theme-based primary text color
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 10),
        ],
        automaticallyImplyLeading: false,
      ),

      endDrawer:
          const AppDrawer(), // Assuming AppDrawer adapts or you style it separately

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
                  color:
                      effectivePrimaryTextColor, // Use theme-based primary text color
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              // Consider having a dark-theme version of the image if needed
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
                  color:
                      effectivePrimaryTextColor, // Use theme-based primary text color
                ),
              ),
            ),
            const SizedBox(height: 15),

            Column(
              children:
                  _recentPatients.map((patient) {
                    bool isBlue = _recentPatients.indexOf(patient) % 2 == 0;
                    return _buildPatientCard(
                      patient: patient,
                      // Pass LIGHT theme colors, the function will handle dark mode
                      lightBackgroundColor:
                          isBlue ? lightBlueCardBg : lightPurpleCardBg,
                      lightAvatarBackgroundColor:
                          isBlue ? lightBlueAvatarBg : lightPurpleAvatarBg,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- Bottom Navigation Bar (Updated for Labels and Dark Theme) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color:
                  isDarkMode
                      ? Colors.grey[700]!
                      : Colors.black12, // Theme-based border
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home', // Keep label text
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: 'Patients', // Keep label text
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Notes', // Keep label text
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile', // Keep label text
            ),
          ],
          currentIndex: _screenIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              effectiveBottomNavColor, // Apply theme-based background
          selectedItemColor:
              effectiveBottomNavSelectedColor, // Apply theme-based selected color
          unselectedItemColor:
              effectiveBottomNavUnselectedColor, // Apply theme-based unselected color
          showSelectedLabels: true, // **** CHANGED: Show labels ****
          showUnselectedLabels: true, // **** CHANGED: Show labels ****
          selectedFontSize: 12.0, // **** CHANGED: Set readable font size ****
          unselectedFontSize: 12.0, // **** CHANGED: Set readable font size ****
          elevation: 5,
        ),
      ),
    );
  }
}
