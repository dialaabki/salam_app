// lib/notifications_screen.dart
import 'package:flutter/material.dart';
// ** Import necessary files **
import 'patientsScreen.dart'; // For Patient class
import 'patientDetailScreen.dart'; // For navigation target

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final int _screenIndex = 0; // Default index

  // --- Asset Paths (keep as is) ---
  final String malePatientImagePath = 'assets/images/malepatientpic.png';
  final String femalePatientImagePath = 'assets/images/femalepatientpic.png';
  final String chartImagePath = 'assets/images/chartpic.png';

  // --- Colors (keep as is) ---
  final Color headerColor = const Color(0xFF5A7A9E);
  final Color primaryTextColor = const Color(0xFF003366);
  // ... other colors ...
  final Color secondaryTextColor = Colors.grey.shade600;
  final Color cardBackgroundColor = const Color(0xFFE0F2F7);
  final Color avatarBackgroundColor = const Color(0xFFB3E5FC);
  final Color purpleCardBg = const Color(0xFFEDE7F6);
  final Color purpleAvatarBg = const Color(0xFFD1C4E9);
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);

  // --- **** ADD DUMMY PATIENT DATA **** ---
  // In a real app, notifications would likely contain patient IDs
  // which you would use to fetch the full Patient object.
  final Patient _moradPatient = Patient(
    id: '1', // Ensure IDs match if used elsewhere
    name: 'Morad',
    age: '34',
    condition: 'Depression',
    avatarPath: 'assets/images/malepatientpic.png',
    avatarBgColor: const Color(0xFFA5D6F0),
  ); // Use actual color if defined elsewhere

  final Patient _laraPatient = Patient(
    id: '2',
    name: 'Lara',
    age: '23',
    condition: 'Anxiety',
    avatarPath: 'assets/images/femalepatientpic.png',
    avatarBgColor: const Color(0xFFD1C4E9),
  );
  // --- **** END DUMMY DATA **** ---

  // --- Helper Method to Build Notification Item (UPDATED) ---
  Widget _buildNotificationItem({
    // --- Require Patient object ---
    required Patient patient,
    required String timeAgo,
    required Color cardBg, // Use this specific card bg
    // avatarBg is now derived from patient object
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Text
          Padding(
            padding: const EdgeInsets.only(left: 5.0, bottom: 8.0),
            child: Text(
              'Weekly progress was sent',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
          ),

          // --- Wrap with InkWell for Tapping ---
          InkWell(
            onTap: () {
              // --- Navigation Action ---
              print("Tapped notification for ${patient.name}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PatientDetailScreen(
                        patient: patient,
                      ), // Pass patient object
                ),
              );
              // --- End Navigation ---
            },
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg, // Use the passed card background
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Avatar (uses patient data)
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          patient.avatarBgColor, // Use patient's bg color
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(
                            patient.avatarPath,
                          ), // Use patient's image
                          backgroundColor: Colors.transparent,
                          onBackgroundImageError: (e, s) {},
                          child:
                              AssetImage(patient.avatarPath) == null
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Patient Info (uses patient data)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF4A4A6A),
                            ),
                          ),
                          // Construct details string from patient data
                          Text(
                            "${patient.age} Years\n${patient.condition}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Chart Image
                    Image.asset(
                      chartImagePath,
                      height: 50,
                      width: 60,
                      errorBuilder: (c, e, s) => const Icon(Icons.error),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- End InkWell ---
          const SizedBox(height: 8),
          // Timestamp
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                timeAgo,
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom Nav Tap Handler (Keep as is) ---
  void _onItemTapped(int index) {
    /* ... same ... */
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
    return Scaffold(
      appBar: AppBar(
        // Using AppBar
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        children: [
          // --- UPDATED calls to pass Patient objects ---
          _buildNotificationItem(
            patient: _moradPatient, // Pass the Patient object
            timeAgo: '5 minutes ago',
            cardBg: cardBackgroundColor, // Pass desired card background
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: Colors.grey[300],
          ),
          _buildNotificationItem(
            patient: _laraPatient, // Pass the Patient object
            timeAgo: 'Today 3:00PM',
            cardBg: purpleCardBg, // Pass desired card background
          ),
          // --- End Update ---
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: Colors.grey[300],
          ),
          // Add more notifications similarly
        ],
      ),

      // --- Bottom Nav (Keep as is) ---
      bottomNavigationBar: Container(
        /* ... same ... */
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: 'Patients',
            ),
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