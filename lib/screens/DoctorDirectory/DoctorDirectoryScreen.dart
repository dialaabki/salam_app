import 'package:flutter/material.dart';
// Removed Timer import as it's not used in this context
// import 'dart:async';

// Data model for a doctor (optional but good practice)
class Doctor {
  final String imagePath;
  final String name;
  final String specialty;
  final String address;
  final String phone;
  final int price;

  Doctor({
    required this.imagePath,
    required this.name,
    required this.specialty,
    required this.address,
    required this.phone,
    required this.price,
  });
}

class DoctorDirectoryScreen extends StatefulWidget {
  const DoctorDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  // _selectedIndex is not needed for BottomAppBar with simple IconButtons
  // int _selectedIndex = 0;

  // --- Doctor Data ---
  final List<Doctor> doctors = [
    Doctor(
      imagePath: 'assets/images/mousapic.png',
      name: 'Mousa Al-Atabi',
      specialty: 'Adult Psychiatry, Addiction',
      address: 'Amman, Mkablein, Al-Sakhrah Al-Mosharafa Street',
      phone: '079-XXX-XXXX',
      price: 50,
    ),
    Doctor(
      imagePath: 'assets/images/larapic.png',
      name: 'Lara Alqam',
      specialty: 'Adult Psychiatry, Addiction',
      address: 'Amman, Fifth Circle, Sulaiman Al-Hadidi Street',
      phone: '079-XXX-XXXX',
      price: 60,
    ),
    Doctor(
      imagePath: 'assets/images/aseelpic.png',
      name: 'Aseel AlDwikat',
      specialty: 'Family Counseling',
      address: 'Amman, Khalda, Wasfi altal street',
      phone: '079-XXX-XXXX',
      price: 30,
    ),
  ];

  // NOTE: If you need a Timer in this screen, declare it here:
  // Timer? _timer;
  // @override
  // void dispose() {
  //   _timer?.cancel(); // Cancel timer when screen is disposed
  //   super.dispose();
  // }

  // --- Define Colors ---
  final Color headerColor = const Color(0xFF5588A4);
  final Color titleColor = const Color(0xFF276181);
  final Color primaryTextColor = const Color(0xFF276181);
  final Color secondaryTextColor = Colors.grey.shade600;
  final Color tertiaryTextColor = Colors.grey.shade500;
  final Color priceColor = Colors.grey.shade700;
  final Color searchBarBg = Colors.grey.shade200;
  final Color searchBarIconColor = Colors.grey.shade500;
  final Color cardBg = Colors.white;
  final Color shadowColor = Colors.grey.withOpacity(0.3);
  // Colors for the new BottomAppBar from your code
  final Color bottomAppBarBg = const Color(0xFF276181);
  final Color bottomAppBarIconColor = const Color(0xFF5E94FF);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(screenHeight),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Find your Doctor',
                      style: TextStyle(
                        fontFamily:
                            'Times New Roman', // Or 'Serif' or your specific font
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildDoctorList(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Use the new bottom navigation bar method
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(double screenHeight) {
    return ClipPath(
      clipper: CurvedHeaderClipper(),
      child: Container(
        height: screenHeight * 0.30,
        color: headerColor,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.04),
              child: Image.asset(
                'assets/images/directorypic.png',
                height: screenHeight * 0.15,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 50,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
          color: searchBarBg,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'name , address , specialty , price , ......',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: searchBarIconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: ListView.builder(
        itemCount: doctors.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildDoctorCard(doctors[index]);
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      elevation: 3.0,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                doctor.imagePath,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 80,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tertiaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.phone,
                    style: TextStyle(fontSize: 11, color: tertiaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor.price} JOD',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED Bottom Navigation Bar ---
  Widget _buildBottomNavBar() {
    // Using your provided BottomAppBar structure
    return BottomAppBar(
      color: bottomAppBarBg, // Use the color specified in your code
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          IconButton(
            // Use the icon color specified in your code
            icon: Icon(Icons.home, color: bottomAppBarIconColor),
            onPressed: () {
              // _timer?.cancel(); // Removed: _timer is not defined in this state
              print("Navigate to Home (Pop until first route)"); // Debug print
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Home', // Optional: Add tooltips for accessibility
          ),

          // Reminders (Clock icon)
          IconButton(
            icon: Icon(Icons.access_time, color: bottomAppBarIconColor),
            onPressed: () {
              // _timer?.cancel(); // Removed: _timer is not defined in this state
              print("Navigate to Reminders (/reminders)"); // Debug print
              // IMPORTANT: Requires named route '/reminders' to be set up in MaterialApp
              Navigator.pushNamed(context, '/reminders');
            },
            tooltip: 'Reminders',
          ),

          // Activity (Checklist icon)
          IconButton(
            icon: Icon(Icons.checklist, color: bottomAppBarIconColor),
            onPressed: () {
              // _timer?.cancel(); // Removed: _timer is not defined in this state
              print("Navigate to Activity (/activity)"); // Debug print
              // IMPORTANT: Requires named route '/activity' to be set up in MaterialApp
              Navigator.pushNamed(context, '/activity');
            },
            tooltip: 'Activity',
          ),

          // Doctor Directory (Book icon)
          IconButton(
            icon: Icon(Icons.menu_book, color: bottomAppBarIconColor),
            onPressed: () {
              // _timer?.cancel(); // Removed: _timer is not defined in this state
              print("Navigate to Doctor Directory (/doctors)"); // Debug print
              // You might already be on this screen, consider disabling or different logic
              // IMPORTANT: Requires named route '/doctors' to be set up in MaterialApp
              Navigator.pushNamed(context, '/doctors');
            },
            tooltip: 'Doctors',
          ),

          // Profile
          IconButton(
            icon: Icon(Icons.person, color: bottomAppBarIconColor),
            onPressed: () {
              // _timer?.cancel(); // Removed: _timer is not defined in this state
              print("Navigate to Profile (/profile)"); // Debug print
              // IMPORTANT: Requires named route '/profile' to be set up in MaterialApp
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Custom Clipper for Curved Header ---
// (Clipper code remains the same)
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height * 0.9);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    final secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.8);
    final secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
