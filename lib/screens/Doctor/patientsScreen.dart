// lib/patients_screen.dart
import 'package:flutter/material.dart';
import 'patientDetailScreen.dart';
// Import main.dart to access route constants (good practice)
import '/main.dart'; // Adjust path if main.dart is elsewhere
// Import theme provider if needed directly (usually accessed via Theme.of(context))
// import '../providers/theme_provider.dart';

// Patient class definition (keep as is)
class Patient {
  final String id;
  final String name;
  final String age;
  final String condition;
  final String avatarPath;
  final Color avatarBgColor;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.avatarPath,
    required this.avatarBgColor,
  });
}

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});
  // Define route name for consistency
  static const routeName = '/patients'; // '/patients'

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  // *** Screen index for Patients Screen ***
  final int _screenIndex = 1;

  // --- UI Constants (Example - Keep your existing constants) ---
  // static const Color headerColor = Color(0xFF5A9AB8); // Use theme colors instead if possible
  // ... other constants ...
  final String headerIllustrationPath = 'assets/images/patientmenupic.png';
  final String maleAvatarPath = 'assets/images/malepatientpic.png';
  final String femaleAvatarPath = 'assets/images/femalepatientpic.png';
  final String chartImagePath = 'assets/images/chartpic.png';

  final TextEditingController _searchController = TextEditingController();
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _allPatients = _getDummyPatients(); // Load your patient data
    _filteredPatients = _allPatients;
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }

  // --- Dummy Data & Filtering (Keep your existing implementations) ---
  List<Patient> _getDummyPatients() {
    // Return your list of patients
    return [
      Patient(
        id: '1',
        name: 'Morad',
        age: '34',
        condition: 'Depression',
        avatarPath: maleAvatarPath,
        avatarBgColor: const Color(0xFFA5D6F0),
      ),
      Patient(
        id: '2',
        name: 'Lara',
        age: '23',
        condition: 'Anxiety',
        avatarPath: femaleAvatarPath,
        avatarBgColor: const Color(0xFFD1C4E9),
      ),
      // ... add all patients
    ];
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients =
            _allPatients.where((patient) {
              final nameLower = patient.name.toLowerCase();
              final conditionLower = patient.condition.toLowerCase();
              final ageString = patient.age;
              return nameLower.contains(query) ||
                  conditionLower.contains(query) ||
                  ageString.contains(query);
            }).toList();
      }
    });
  }

  // --- Patient Card Widget (Keep your existing implementation) ---
  Widget _buildPatientCard({required Patient patient}) {
    // Use Theme.of(context) for colors if adapting for dark mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? Colors.grey[800] : const Color(0xFFE7F0F5);
    final primaryTextColor =
        isDarkMode ? Colors.white70 : const Color(0xFF5A7A9E);
    final avatarOuterBg =
        isDarkMode
            ? patient.avatarBgColor.withOpacity(0.6)
            : patient.avatarBgColor;

    return Padding(
      /* ... */
      // Your existing card structure
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailScreen(patient: patient),
              ),
            ),
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor, // Apply theme-based color
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [/* Your shadows */],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: avatarOuterBg, // Theme-based outer bg
                  child: CircleAvatar(
                    // Inner avatar with image
                    radius: 28, // Slightly smaller
                    backgroundImage: AssetImage(patient.avatarPath),
                    backgroundColor: Colors.transparent,
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
                          fontSize: 17,
                          color: primaryTextColor, // Theme-based text color
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${patient.age} Years\n${patient.condition}",
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryTextColor, // Theme-based text color
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(chartImagePath, height: 50, width: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- *** UPDATED Bottom Nav Tap Handler *** ---
  void _onItemTapped(int index) {
    if (index == _screenIndex)
      return; // Do nothing if tapping the current screen

    // Use the route names defined in main.dart
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(
          context,
          '/doctor_home',
        ); // Use '/doctor_home'
        break;
      case 1: // Patients (Current Screen)
        // Already here, do nothing
        break;
      case 2: // Notes
        Navigator.pushReplacementNamed(context, '/notes'); // Use '/notes'
        break;
      case 3: // Profile
        Navigator.pushReplacementNamed(context, '/profile'); // Use '/profile'
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Define Effective Colors based on Theme ---
    // Bottom Nav Colors (Example matching DoctorHomeScreen)
    final Color effectiveBottomNavColor =
        isDarkMode ? Colors.grey[900]! : const Color(0xFF004A99);
    final Color effectiveBottomNavSelectedColor =
        isDarkMode ? Colors.tealAccent[100]! : Colors.white;
    final Color effectiveBottomNavUnselectedColor =
        isDarkMode ? Colors.grey[500]! : const Color(0xFFADD8E6);

    // Header Colors (Adapt if needed)
    final Color effectiveHeaderColor =
        isDarkMode ? Colors.grey[850]! : const Color(0xFF5A9AB8);
    final Color effectiveHeaderTextColor =
        isDarkMode ? Colors.white : const Color(0xFF003366);

    // Search Bar Colors (Adapt if needed)
    final Color effectiveSearchBarColor =
        isDarkMode ? Colors.grey[700]! : const Color(0xFFF0F0F0);
    final Color effectiveSearchBarTextColor =
        isDarkMode ? Colors.white70 : Colors.grey;
    final Color effectiveIconColor =
        isDarkMode ? Colors.white54 : Colors.grey[600]!;

    return Scaffold(
      // Use theme's background color or a specific one
      backgroundColor: effectiveHeaderColor, // Background for the top part
      body: Stack(
        children: [
          // --- Header ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              color: effectiveHeaderColor, // Use theme-adapted color
              child: SafeArea(
                /* Your Header Content */
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 25.0,
                    right: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Patients",
                        style: TextStyle(
                          color:
                              effectiveHeaderTextColor, // Use theme-adapted color
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(headerIllustrationPath, height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // --- Content Area ---
          Positioned.fill(
            top: 145, // Adjust overlap as needed
            child: Container(
              decoration: BoxDecoration(
                // Use the general scaffold background color for the main content area
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // --- Search Bar ---
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25.0,
                      left: 20.0,
                      right: 20.0,
                      bottom: 15.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color:
                            effectiveSearchBarColor, // Use theme-adapted color
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ), // Input text color
                        decoration: InputDecoration(
                          icon: Icon(Icons.tune, color: effectiveIconColor),
                          hintText: "Search by name, condition, age...",
                          hintStyle: TextStyle(
                            color: effectiveSearchBarTextColor,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: effectiveIconColor,
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                  : Icon(
                                    Icons.search,
                                    color: effectiveIconColor,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  // --- Patient List ---
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredPatients.length,
                      itemBuilder:
                          (context, index) => _buildPatientCard(
                            patient: _filteredPatients[index],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // --- *** UPDATED Bottom Navigation Bar (Using Theme Colors) *** ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ), // Index 0
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Patients',
            ), // Index 1 (Filled icon when selected)
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Notes',
            ), // Index 2
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ), // Index 3
          ],
          currentIndex: _screenIndex, // Should be 1 for PatientsScreen
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: effectiveBottomNavColor, // Apply theme color
          selectedItemColor:
              effectiveBottomNavSelectedColor, // Apply theme color
          unselectedItemColor:
              effectiveBottomNavUnselectedColor, // Apply theme color
          showSelectedLabels: true, // Show labels
          showUnselectedLabels: true, // Show labels
          selectedFontSize: 12.0, // Consistent font size
          unselectedFontSize: 12.0, // Consistent font size
          elevation: 5,
          // Optional: Adjust icon themes if needed, but colors above handle most cases
          // selectedIconTheme: IconThemeData(size: 28, color: effectiveBottomNavSelectedColor),
          // unselectedIconTheme: IconThemeData(size: 24, color: effectiveBottomNavUnselectedColor),
        ),
      ),
    );
  }
}