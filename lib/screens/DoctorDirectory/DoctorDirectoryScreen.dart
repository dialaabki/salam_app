import 'package:flutter/material.dart';

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
  const DoctorDirectoryScreen({super.key});

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  // --- Search State ---
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _filteredDoctors = []; // List to hold filtered results
  String _searchQuery = '';

  // --- Doctor Data (Original Full List) ---
  // Make this final as it shouldn't change after initialization
  final List<Doctor> _allDoctors = [
    Doctor(
      imagePath: 'assets/images/mousapic.png', // Ensure these paths are correct
      name: 'Mousa Al-Atabi',
      specialty: 'Adult Psychiatry, Addiction',
      address: 'Amman, Mkablein, Al-Sakhrah Al-Mosharafa Street',
      phone: '079-XXX-XXXX',
      price: 50,
    ),
    Doctor(
      imagePath: 'assets/images/larapic.png', // Ensure these paths are correct
      name: 'Lara Alqam',
      specialty: 'Adult Psychiatry, Addiction',
      address: 'Amman, Fifth Circle, Sulaiman Al-Hadidi Street',
      phone: '079-XXX-XXXX',
      price: 60,
    ),
    Doctor(
      imagePath: 'assets/images/aseelpic.png', // Ensure these paths are correct
      name: 'Aseel AlDwikat',
      specialty: 'Family Counseling',
      address: 'Amman, Khalda, Wasfi altal street',
      phone: '079-XXX-XXXX',
      price: 30,
    ),
    Doctor(
      imagePath: 'assets/images/another_doc.png', // Example: Add more doctors
      name: 'Dr. Test Example',
      specialty: 'General Psychiatry',
      address: 'Irbid, University Street',
      phone: '077-XXX-XXXX',
      price: 45,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initially, show all doctors
    _filteredDoctors = _allDoctors;
    // Add listener to controller for real-time search updates
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  // --- Search Logic ---
  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery =
          query; // Update the state variable (optional, but can be useful)
      if (_searchQuery.isEmpty) {
        // If search is empty, show all doctors
        _filteredDoctors = _allDoctors;
      } else {
        // Otherwise, filter the list
        _filteredDoctors =
            _allDoctors.where((doctor) {
              final nameLower = doctor.name.toLowerCase();
              final specialtyLower = doctor.specialty.toLowerCase();
              final addressLower = doctor.address.toLowerCase();
              final priceString =
                  doctor.price.toString(); // Search price as string

              // Check if query matches any relevant field
              return nameLower.contains(_searchQuery) ||
                  specialtyLower.contains(_searchQuery) ||
                  addressLower.contains(_searchQuery) ||
                  priceString.contains(
                    _searchQuery,
                  ); // Check if price contains the query digits
            }).toList(); // Convert the Iterable result back to a List
      }
    });
  }

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
              // Keep the list scrollable if it exceeds screen height
              child: Column(
                // Make the column take minimum space vertically initially
                // mainAxisSize: MainAxisSize.min,
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
                  _buildSearchBar(), // Search bar triggers filtering
                  const SizedBox(height: 20),
                  _buildDoctorList(), // List displays filtered results
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(double screenHeight) {
    // (Header code remains the same)
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
                'assets/images/directorypic.png', // Ensure path is correct
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
          controller: _searchController, // Assign the controller
          // onChanged: (query) => _performSearch(query), // Alternative: Use onChanged directly
          decoration: InputDecoration(
            hintText: 'name , address , specialty , price , ......',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none, // Removes the underline
            icon: Icon(Icons.search, color: searchBarIconColor),
            // Add a clear button if the search bar has text
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: searchBarIconColor),
                      onPressed: () {
                        _searchController.clear(); // Clears the text field
                        // _performSearch is called automatically by the listener
                      },
                      tooltip: 'Clear search',
                    )
                    : null, // Show nothing if search bar is empty
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    // Display message if no doctors match the search
    if (_filteredDoctors.isEmpty && _searchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Center(
          child: Text(
            'No doctors found matching "$_searchQuery"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryTextColor),
          ),
        ),
      );
    }
    // Display message if the initial list is somehow empty
    else if (_filteredDoctors.isEmpty && _searchQuery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Center(
          child: Text(
            'No doctors available.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryTextColor),
          ),
        ),
      );
    }

    // Build the list using the FILTERED doctors
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: ListView.builder(
        // Use the filtered list count
        itemCount: _filteredDoctors.length,
        shrinkWrap: true, // Important inside a Column/SingleChildScrollView
        physics:
            const NeverScrollableScrollPhysics(), // List shouldn't scroll independently here
        itemBuilder: (context, index) {
          // Use the filtered list data
          return _buildDoctorCard(_filteredDoctors[index]);
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    // (Doctor card code remains the same)
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
                doctor.imagePath, // Ensure path is correct
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
    // (Bottom nav bar code remains the same)
    return BottomAppBar(
      color: bottomAppBarBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: bottomAppBarIconColor),
            onPressed: () {
              print("Navigate to Home (Pop until first route)");
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Home',
          ),
          IconButton(
            icon: Icon(Icons.access_time, color: bottomAppBarIconColor),
            onPressed: () {
              print("Navigate to Reminders (/reminders)");
              // Make sure '/reminders' is defined in your MaterialApp routes
              Navigator.pushNamed(context, '/reminders');
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: Icon(Icons.checklist, color: bottomAppBarIconColor),
            onPressed: () {
              print("Navigate to Activity (/activity)");
              // Make sure '/activity' is defined in your MaterialApp routes
              Navigator.pushNamed(context, '/activity');
            },
            tooltip: 'Activity',
          ),
          IconButton(
            icon: Icon(Icons.menu_book, color: bottomAppBarIconColor),
            onPressed: () {
              print("Navigate to Doctor Directory (/doctors)");
              // Optional: Could add logic to prevent navigating if already here
              // Make sure '/doctors' is defined in your MaterialApp routes
              // Navigator.pushNamed(context, '/doctors'); // Might cause issues if already here
              // If using pushNamed, ensure you handle potential duplicate pushes or use pushReplacementNamed
            },
            tooltip: 'Doctors',
          ),
          IconButton(
            icon: Icon(Icons.person, color: bottomAppBarIconColor),
            onPressed: () {
              print("Navigate to Profile (/profile)");
              // Make sure '/profile' is defined in your MaterialApp routes
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
class CurvedHeaderClipper extends CustomClipper<Path> {
  // (Clipper code remains the same)
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
