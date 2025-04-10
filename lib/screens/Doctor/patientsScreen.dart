// lib/patients_screen.dart
import 'package:flutter/material.dart';
import 'patientDetailScreen.dart';

// Patient class definition (keep as is)
class Patient {
  final String id;
  final String name;
  final String age; // Age is already a String here
  final String condition;
  final String avatarPath;
  final Color avatarBgColor;

  Patient({
    /* constructor */
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
  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  // ... (keep existing variables and initState, dispose, etc.) ...
  final int _screenIndex = 1;
  static const Color headerColor = Color(0xFF5A9AB8);
  static const Color headerTextColor = Color(0xFF003366);
  static const Color searchBarColor = Color(0xFFF0F0F0);
  static const Color searchBarTextColor = Colors.grey;
  static const Color patientCardBackground = Color(0xFFE7F0F5);
  static const Color patientTextColor = Color(0xFF5A7A9E);
  static const Color maleAvatarBg = Color(0xFFA5D6F0);
  static const Color femaleAvatarBg = Color(0xFFD1C4E9);
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);
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
    _allPatients = _getDummyPatients();
    _filteredPatients = _allPatients;
    _searchController.addListener(_filterPatients);
  }

  List<Patient> _getDummyPatients() {
    /* ... same ... */
    return [
      Patient(
        id: '1',
        name: 'Morad',
        age: '34',
        condition: 'Depression',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '2',
        name: 'Lara',
        age: '23',
        condition: 'Anxiety',
        avatarPath: femaleAvatarPath,
        avatarBgColor: femaleAvatarBg,
      ),
      Patient(
        id: '3',
        name: 'Tamer',
        age: '28',
        condition: 'Addiction',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '4',
        name: 'Sameer',
        age: '40',
        condition: 'OCD',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '5',
        name: 'Ahmad',
        age: '29',
        condition: 'Depression',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '6',
        name: 'Sara',
        age: '20',
        condition: 'Anxiety',
        avatarPath: femaleAvatarPath,
        avatarBgColor: femaleAvatarBg,
      ),
      Patient(
        id: '7',
        name: 'Omar',
        age: '18',
        condition: 'ADHD',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '8',
        name: 'Mohammed',
        age: '27',
        condition: 'OCD',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }

  // --- UPDATED _filterPatients ---
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
              final ageString = patient.age; // Age is already a string

              return nameLower.contains(query) ||
                  conditionLower.contains(query) ||
                  ageString.contains(query); // <-- ADDED age search
            }).toList();
      }
      // Optionally sort results
      // _filteredPatients.sort((a, b) => a.name.compareTo(b.name));
    });
  }
  // --- End Update ---

  // --- Patient Card Widget (Keep as is) ---
  Widget _buildPatientCard({required Patient patient}) {
    /* ... same ... */
    return Padding(
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
            color: patientCardBackground,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
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
                  backgroundColor: patient.avatarBgColor,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(patient.avatarPath),
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError: (e, s) {},
                    child:
                        AssetImage(patient.avatarPath) == null
                            ? const Icon(Icons.person)
                            : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: patientTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${patient.age} Years\n${patient.condition}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: patientTextColor,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  chartImagePath,
                  height: 50,
                  width: 60,
                  errorBuilder: (c, e, s) => const Icon(Icons.error_outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Bottom Nav Tap Handler (Keep as is) ---
  void _onItemTapped(int index) {
    /* ... same ... */
    if (index == _screenIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
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
    // ... build method structure remains the same ...
    // Update hint text in search bar
    return Scaffold(
      backgroundColor: headerColor,
      body: Stack(
        children: [
          // --- Header (keep as is) ---
          Positioned(
            /* ... */
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              color: headerColor,
              child: SafeArea(
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
                      const Text(
                        "Patients",
                        style: TextStyle(
                          color: headerTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(
                        headerIllustrationPath,
                        height: 100,
                        errorBuilder:
                            (c, e, s) => const SizedBox(
                              height: 100,
                              width: 120,
                              child: Center(
                                child: Icon(
                                  Icons.groups,
                                  color: Colors.white70,
                                  size: 50,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // --- Content Area ---
          Positioned.fill(
            top: 145,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // --- Search Bar (Update Hint Text) ---
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
                        color: searchBarColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.tune, color: Colors.grey[600]),
                          hintText:
                              "Search by name, condition, age...", // <-- UPDATED HINT
                          hintStyle: TextStyle(
                            color: searchBarTextColor,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                  : Icon(Icons.search, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                  // --- Patient List (keep as is) ---
                  Expanded(
                    /* ... */
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
      // --- Bottom Nav (keep as is) ---
      bottomNavigationBar: Container(
        /* ... */
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
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
