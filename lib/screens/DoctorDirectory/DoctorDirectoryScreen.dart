// lib/screens/DoctorDirectory/DoctorDirectoryScreen.dart
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // No longer needed if not adding doctors
// Adjust the import path if your service file is located elsewhere
import '../../services/mongo_api_service.dart';

// Updated Doctor Data Model
class Doctor {
  final String id; // From MongoDB _id
  final String? imageUrl; // Will be a URL from backend (nullable)
  final String name;
  final String specialty;
  final String clinicAddress; // Matches backend 'clinicAddress'
  final String phoneNumber;   // Matches backend 'phoneNumber'
  final int? price; // Can be nullable if not always present

  Doctor({
    required this.id,
    this.imageUrl,
    required this.name,
    required this.specialty,
    required this.clinicAddress,
    required this.phoneNumber,
    this.price,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'N/A',
      specialty: json['specialty'] as String? ?? 'N/A',
      clinicAddress: json['clinicAddress'] as String? ?? 'N/A',
      phoneNumber: json['phoneNumber'] as String? ?? 'N/A',
      imageUrl: json['imageUrl'] as String?,
      price: json['price'] as int?,
    );
  }

  // toJsonForCreation might still be useful if you plan to add doctors via other means later
  // or if other parts of the app use it. If not, it can also be removed from this model.
  Map<String, dynamic> toJsonForCreation() {
    return {
      'name': name,
      'specialty': specialty,
      'clinicAddress': clinicAddress,
      'phoneNumber': phoneNumber,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
    };
  }
}

class DoctorDirectoryScreen extends StatefulWidget {
  const DoctorDirectoryScreen({super.key});

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  final MongoApiService _apiService = MongoApiService();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final doctors = await _apiService.getDoctors();
      if (!mounted) return;
      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print("Error in _fetchDoctors: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _performSearch() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredDoctors = _allDoctors;
      } else {
        _filteredDoctors = _allDoctors.where((doctor) {
          final nameLower = doctor.name.toLowerCase();
          final specialtyLower = doctor.specialty.toLowerCase();
          final addressLower = doctor.clinicAddress.toLowerCase();
          final priceString = doctor.price?.toString() ?? '';

          return nameLower.contains(_searchQuery) ||
              specialtyLower.contains(_searchQuery) ||
              addressLower.contains(_searchQuery) ||
              (priceString.isNotEmpty && priceString.contains(_searchQuery));
        }).toList();
      }
    });
  }

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

  // --- _showAddDoctorDialog method can be removed if no longer needed ---
  /*
  void _showAddDoctorDialog() {
    // ... (implementation was here) ...
  }
  */

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(screenHeight),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 50),
                              const SizedBox(height: 10),
                              Text('Error: $_errorMessage', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _fetchDoctors,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryTextColor),
                                child: const Text('Retry Fetching Doctors', style: TextStyle(color: Colors.white))
                              )
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Find your Doctor',
                                style: TextStyle(
                                  fontFamily: 'Times New Roman',
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
                            // const SizedBox(height: 70), // Space for FAB can be removed or adjusted
                          ],
                        ),
                      ),
          ),
        ],
      ),
      // --- REMOVED FloatingActionButton ---
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showAddDoctorDialog,
      //   tooltip: 'Add Doctor',
      //   backgroundColor: primaryTextColor,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, color: Colors.white70, size: 50),
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
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'name , address , specialty , price , ......',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: searchBarIconColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: searchBarIconColor),
                    onPressed: () {
                      _searchController.clear();
                    },
                    tooltip: 'Clear search',
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    if (_filteredDoctors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Center(
          child: Text(
            _isLoading
                ? 'Loading doctors...'
                : _searchQuery.isNotEmpty
                    ? 'No doctors found matching "$_searchQuery"'
                    : (_allDoctors.isEmpty && !_isLoading)
                        ? 'No doctors available in the directory at the moment.'
                        : 'No doctors match your current criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryTextColor),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: ListView.builder(
        itemCount: _filteredDoctors.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildDoctorCard(_filteredDoctors[index]);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty
                  ? Image.network(
                      doctor.imageUrl!,
                      width: 80,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(width: 80, height: 100),
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : _imageErrorPlaceholder(width: 80, height: 100),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.clinicAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tertiaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.phoneNumber,
                    style: TextStyle(fontSize: 11, color: tertiaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.price != null ? '${doctor.price} JOD' : 'Price not available',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: priceColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageErrorPlaceholder({double width = 80, double height = 100}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Icon(Icons.person_outline, color: Colors.grey[400], size: 40),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: bottomAppBarBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: bottomAppBarIconColor),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Home',
          ),
          IconButton(
            icon: Icon(Icons.access_time, color: bottomAppBarIconColor),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/reminders') {
                Navigator.pushNamed(context, '/reminders');
              }
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: Icon(Icons.checklist, color: bottomAppBarIconColor),
            onPressed: () {
               if (ModalRoute.of(context)?.settings.name != '/activity') {
                Navigator.pushNamed(context, '/activity');
              }
            },
            tooltip: 'Activity',
          ),
          IconButton(
            icon: Icon(Icons.menu_book, color: bottomAppBarIconColor),
            onPressed: () { /* Already on doctors screen, or handle appropriately */},
            tooltip: 'Doctors',
          ),
          IconButton(
            icon: Icon(Icons.person, color: bottomAppBarIconColor),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/profile') {
                Navigator.pushNamed(context, '/profile');
              }
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height * 0.9);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    final secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.8);
    final secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}