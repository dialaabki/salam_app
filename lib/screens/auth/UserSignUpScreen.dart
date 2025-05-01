// File: lib/screens/auth/UserSignUpScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <<< Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< Import Firestore

// TODO: Import the screen you want to navigate to after successful signup
// Example: import '../UserHomeScreen.dart';
// Example: import '../../main.dart'; // If using MyApp.userHomeRoute

class UserSignUpScreen extends StatefulWidget {
  const UserSignUpScreen({super.key});

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  // --- Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specifyController = TextEditingController();

  // --- State Variables ---
  String? _gender;
  String? _substanceUse; // Stores 'Yes' or 'No' from radio button
  String _birthDateDisplay = 'DD/MM/YYYY'; // For display purposes only
  DateTime? _selectedBirthDate; // Store the actual DateTime object for Firestore

  // --- Loading State ---
  bool _isLoading = false;

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Signup Function ---
  Future<void> _signUp() async {
    // --- 1. Basic Validation ---
    // (Ensure required fields are filled - add more specific validation as needed)
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _gender == null ||
        _selectedBirthDate == null ||
        _substanceUse == null ||
        (_substanceUse == 'Yes' && _specifyController.text.trim().isEmpty)) {
      if (mounted) { // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all required fields (*).'),
              backgroundColor: Colors.red),
        );
      }
      return; // Stop execution if validation fails
    }

    // --- 2. Start Loading ---
    setState(() { _isLoading = true; });

    try {
      // --- 3. Create User with Firebase Auth ---
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(), // Use the collected password
      );

      User? user = userCredential.user;

      if (user != null) {
        // --- 4. Save User Data to Firestore ---
        // Using user.uid as the document ID for easy lookup
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'fullName': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}', // Optional combined name
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(), // Optional, save if entered
          'gender': _gender,
          'birthDate': Timestamp.fromDate(_selectedBirthDate!), // Store as Firestore Timestamp
          'substanceUse': _substanceUse == 'Yes', // Store as boolean true/false
          'substanceDetails':
              _substanceUse == 'Yes' ? _specifyController.text.trim() : null, // Store details only if 'Yes'
          'role': 'user', // Explicitly set the role for this signup screen
          'createdAt': FieldValue.serverTimestamp(), // Record creation time on the server
          // Add any other fields you need
        });

        // --- 5. Optional: Send Email Verification ---
        // Consider adding this for better security
        // await user.sendEmailVerification();
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //    const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
        //   );
        // }

        // --- 6. Navigate on Success ---
        if (mounted) { // Check if the widget is still in the tree before navigating
          // Navigate to the User Home Screen and remove all previous routes
          // Replace '/home' with your actual home route name (e.g., MyApp.userHomeRoute)
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home', // <<<---- CHANGE THIS TO YOUR ACTUAL HOME ROUTE
            (Route<dynamic> route) => false,
          );
        }
      } else {
         // Handle case where user is null after creation (shouldn't usually happen)
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Signup failed: Could not get user details.'), backgroundColor: Colors.red)
            );
          }
      }
    } on FirebaseAuthException catch (e) {
      // --- 7. Handle Specific Auth Errors ---
      String errorMessage = 'Signup failed. Please try again.'; // Default message
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak (min 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // Log for debugging
      if (mounted) { // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      // --- 8. Handle Other Errors (Firestore, Network, etc.) ---
       print('General Error during signup: $e'); // Log detailed error
       if (mounted) { // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
                content: Text('An unexpected error occurred. Please try again.'),
                backgroundColor: Colors.red));
       }
    } finally {
      // --- 9. Stop Loading ---
      if (mounted) { // Check if widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // --- UI Code (Mostly unchanged, only button logic updated) ---
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Adjust base width if needed

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: const Color(0xFF276181)),
          // White container
          Positioned(
            top: 50 * scaleFactor, // Adjust top position as needed
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * scaleFactor,
                  vertical: 20 * scaleFactor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'DavidLibre', // Make sure font is included
                          fontWeight: FontWeight.bold,
                          fontSize: 40 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // --- All your form fields go here ---
                    // First Name
                    _buildLabelWithAsterisk('First Name', scaleFactor),
                    _buildTextField(_firstNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),

                    // Last Name
                    _buildLabelWithAsterisk('Last Name', scaleFactor),
                    _buildTextField(_lastNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),

                    // Email
                    _buildLabelWithAsterisk('Email', scaleFactor),
                    _buildTextField(_emailController, scaleFactor, keyboardType: TextInputType.emailAddress), // Set keyboard type
                    SizedBox(height: 15 * scaleFactor),

                    // Password
                    _buildLabelWithAsterisk('Password', scaleFactor),
                    _buildTextField(
                      _passwordController,
                      scaleFactor,
                      isPassword: true,
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Phone Number (Optional)
                    _buildLabel('Phone number', scaleFactor),
                    Row(
                      children: [
                        Container( // Country Code Prefix
                          width: 70 * scaleFactor,
                          height: 55 * scaleFactor,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(25 * scaleFactor),
                          ),
                          child: Center(child: Text('+962', style: TextStyle(fontSize: 16 * scaleFactor))),
                        ),
                        SizedBox(width: 10 * scaleFactor),
                        Expanded(child: _buildTextField(_phoneController, scaleFactor, keyboardType: TextInputType.phone)), // Set keyboard type
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Gender
                    Row( // Gender Label Row
                      children: [
                        Text('Gender', style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6))),
                        Text(' *', style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor)),
                      ],
                    ),
                    SizedBox(height: 5 * scaleFactor),
                    Row( // Gender Radio Buttons
                      children: [
                        _buildRadioButton('Male', scaleFactor),
                        SizedBox(width: 20 * scaleFactor),
                        _buildRadioButton('Female', scaleFactor),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Date of Birth
                    _buildLabelWithAsterisk('Date of birth', scaleFactor),
                    GestureDetector( // Date Picker Trigger
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity, height: 55 * scaleFactor,
                        padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
                        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(25 * scaleFactor)),
                        child: Align(alignment: Alignment.centerLeft,
                          child: Text(_birthDateDisplay, style: TextStyle(fontSize: 16 * scaleFactor, color: _selectedBirthDate == null ? Colors.grey : Colors.black)),
                        ),
                      ),
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Substance Use Question
                    RichText( // Substance Label
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 16 * scaleFactor, color: const Color(0xFFA6A6A6)),
                        children: [ const TextSpan(text: '* ', style: TextStyle(color: Colors.red)), const TextSpan(text: 'Do you currently use any substances or medications that can alter your mood, perception, or mental state?') ],
                      ),
                    ),
                    SizedBox(height: 5 * scaleFactor),
                    Row( // Substance Radio Buttons
                      children: [
                        _buildSubstanceRadioButton('Yes', scaleFactor),
                        SizedBox(width: 20 * scaleFactor),
                        _buildSubstanceRadioButton('No', scaleFactor),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Specify Field (Conditional)
                    if (_substanceUse == 'Yes') ...[
                      _buildTextField(_specifyController, scaleFactor, hintText: 'please specify'),
                      SizedBox(height: 15 * scaleFactor),
                    ],

                    // --- Sign Up Button (with loading state) ---
                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor,
                        height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp, // Disable button when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5588A4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25 * scaleFactor)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator( // Show loader
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                )
                              : Text( // Show text
                                  'Sign up',
                                  style: TextStyle(
                                    fontFamily: 'Commissioner',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20 * scaleFactor, // Adjusted size slightly
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor), // Padding at the bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Label without asterisk
  Widget _buildLabel(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner', fontWeight: FontWeight.bold,
          fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  // Label with red asterisk
  Widget _buildLabelWithAsterisk(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Commissioner', fontWeight: FontWeight.bold,
              fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6),
            ),
          ),
          Text(' *', style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor)),
        ],
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField(
    TextEditingController controller,
    double scaleFactor, {
    bool isPassword = false,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text, // Added keyboardType
  }) {
    return SizedBox(
      height: 55 * scaleFactor, // Fixed height helps alignment
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType, // Use passed keyboardType
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: const Color(0xFFEEEEEE), // Light grey background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25 * scaleFactor),
            borderSide: BorderSide.none, // No border
          ),
          // Adjust padding to vertically center text better
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor, vertical: (55 * scaleFactor - (16*scaleFactor * 1.5)) / 2), // Approximate vertical centering
          hintStyle: TextStyle(fontSize: 16 * scaleFactor, color: Colors.grey[600]),
        ),
        style: TextStyle(fontSize: 16 * scaleFactor), // Set text style
      ),
    );
  }

  // Radio button for Gender
  Widget _buildRadioButton(String value, double scaleFactor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value, groupValue: _gender,
          onChanged: (String? newValue) { setState(() { _gender = newValue; }); },
          activeColor: const Color(0xFF5588A4), // Your app's accent color
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces padding
        ),
        // Add padding to make text easier to tap
        InkWell(
            onTap: () { setState(() { _gender = value; }); },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(value, style: TextStyle(fontSize: 16 * scaleFactor)),
            ),
        ),
      ],
    );
  }

  // Radio button for Substance Use
  Widget _buildSubstanceRadioButton(String value, double scaleFactor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value, groupValue: _substanceUse,
          onChanged: (String? newValue) { setState(() { _substanceUse = newValue; }); },
          activeColor: const Color(0xFF5588A4), // Your app's accent color
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
         InkWell(
            onTap: () { setState(() { _substanceUse = value; }); },
             child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(value, style: TextStyle(fontSize: 16 * scaleFactor)),
            ),
         ),
      ],
    );
  }

  // Date Picker Function (Updated to store DateTime)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago or last selected
      firstDate: DateTime(1920), // Adjust reasonable first date
      lastDate: DateTime.now(),
       builder: (context, child) { // Optional: Apply theme to date picker
        return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: Theme.of(context).colorScheme.copyWith(
               primary: const Color(0xFF5588A4), // Header background
               onPrimary: Colors.white, // Header text
               onSurface: Colors.black, // Body text
             ),
             textButtonTheme: TextButtonThemeData(
               style: TextButton.styleFrom(
                 foregroundColor: const Color(0xFF5588A4), // Button text
               ),
             ),
           ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked; // Store the actual DateTime
        // Format the display string (consider using intl package for better formatting later)
        _birthDateDisplay = "${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}";
      });
    }
  }

  // --- Dispose Controllers ---
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _specifyController.dispose();
    super.dispose();
  }
}