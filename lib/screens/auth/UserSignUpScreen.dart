// File: lib/screens/auth/UserSignUpScreen.dart

// import 'dart:math'; // Removed: For min function (not used)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import main.dart for route constants
// Ensure this path is correct for your project structure
import '../../main.dart'; // Assuming main.dart is two levels up

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
  String? _substanceUse; // Stores 'Yes' or 'No'
  String _birthDateDisplay = 'DD/MM/YYYY';
  DateTime? _selectedBirthDate;

  // --- Loading State ---
  bool _isLoading = false;

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Password Validation Function ---
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return 'Password must contain at least one digit.';
    }
    // Corrected regex: removed redundant '|'
    if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>_+-=\[\]\\;\''`/~`])').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null; // Password is valid
  }

  Future<void> _signUp() async {
    if (!mounted) return;

    // --- 1. Basic Field Validation (Required Fields) ---
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _gender == null ||
        _selectedBirthDate == null ||
        _substanceUse == null ||
        (_substanceUse == 'Yes' && _specifyController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields (*).'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // --- Advanced Password Validation ---
    final password = _passwordController.text.trim();
    final passwordValidationError = _validatePassword(password);
    if (passwordValidationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordValidationError),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String generalErrorMessage = 'An unexpected error occurred during sign up.';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: password, // Use the validated & trimmed password
          );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'fullName':
              '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'gender': _gender,
          'birthDate': Timestamp.fromDate(_selectedBirthDate!),
          'substanceUse': _substanceUse == 'Yes',
          'substanceDetails':
              _substanceUse == 'Yes' ? _specifyController.text.trim() : null,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
        });

        if (!user.emailVerified) {
          try {
            await user.sendEmailVerification();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Signup successful! Verification email sent. Please check your inbox and verify your email before logging in.',
                  ),
                  duration: Duration(seconds: 7),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print("Error sending verification email: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Signup successful, but failed to send verification email: ${e.toString().replaceFirst("Exception: ", "")}',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup successful! Your email was already verified.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, MyApp.loginRoute);
        }
      } else {
        generalErrorMessage = 'Signup failed: Could not retrieve user details after creation.';
        throw Exception(generalErrorMessage); // This will be caught by the generic catch block
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during signup: CODE='${e.code}' MESSAGE='${e.message}'");
      switch (e.code) {
        case 'weak-password':
        case 'auth/weak-password':
          generalErrorMessage = 'The password from Firebase is too weak. Please ensure it meets complexity requirements.';
          break;
        case 'email-already-in-use':
        case 'auth/email-already-in-use':
          generalErrorMessage = 'An account already exists for that email. Please try logging in.';
          break;
        case 'invalid-email':
        case 'auth/invalid-email':
          generalErrorMessage = 'The email address is not validly formatted.';
          break;
        case 'operation-not-allowed':
        case 'auth/operation-not-allowed':
          generalErrorMessage = 'Email/password accounts are not enabled. Contact support.';
          break;
        case 'network-request-failed':
        case 'auth/network-request-failed':
          generalErrorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          generalErrorMessage = e.message ?? 'Signup failed (Code: ${e.code}).';
          if (e.code.toLowerCase().contains('internal-error') || e.code.toLowerCase().contains('unknown-error')) {
            generalErrorMessage = 'An internal server error occurred during signup. Please try again later.';
          }
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(generalErrorMessage), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      print('General Error during signup: $e');
      if (mounted) {
        // If generalErrorMessage was updated by a specific throw before this catch block
        String displayError = generalErrorMessage != 'An unexpected error occurred during sign up.'
                              ? generalErrorMessage
                              : e.toString().replaceFirst("Exception: ", "");
        if (e is FirebaseException && generalErrorMessage == 'An unexpected error occurred during sign up.') {
             displayError = e.message ?? "A database error occurred.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $displayError'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  // --- UI Build Method and Helpers ---
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375;

    return Scaffold(
      // Added AppBar for back navigation
      appBar: AppBar(
        backgroundColor: const Color(0xFF276181), // Match background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF276181)),
          Positioned(
            // Adjusted top to give space for AppBar
            top: 20 * scaleFactor, // Reduced top margin
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
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 40 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                    _buildLabelWithAsterisk('First Name', scaleFactor),
                    _buildTextField(_firstNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),
                    _buildLabelWithAsterisk('Last Name', scaleFactor),
                    _buildTextField(_lastNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),
                    _buildLabelWithAsterisk('Email', scaleFactor),
                    _buildTextField(
                      _emailController,
                      scaleFactor,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15 * scaleFactor),
                    _buildLabelWithAsterisk('Password', scaleFactor),
                    _buildTextField(
                      _passwordController,
                      scaleFactor,
                      isPassword: true,
                    ),
                    SizedBox(height: 15 * scaleFactor),
                    _buildLabel('Phone number', scaleFactor),
                    Row(
                      children: [
                        Container(
                          width: 70 * scaleFactor,
                          height: 55 * scaleFactor,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(25 * scaleFactor),
                          ),
                          child: Center(child: Text('+962', style: TextStyle(fontSize: 16 * scaleFactor))),
                        ),
                        SizedBox(width: 10 * scaleFactor),
                        Expanded(
                          child: _buildTextField(
                            _phoneController,
                            scaleFactor,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),
                    Row(children: [
                      Text('Gender', style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6))),
                      Text(' *', style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor)),
                    ]),
                    SizedBox(height: 5 * scaleFactor),
                    Row(children: [
                      _buildRadioButton('Male', scaleFactor),
                      SizedBox(width: 20 * scaleFactor),
                      _buildRadioButton('Female', scaleFactor),
                    ]),
                    SizedBox(height: 15 * scaleFactor),
                    _buildLabelWithAsterisk('Date of birth', scaleFactor),
                    GestureDetector(
                      onTap: _isLoading ? null : () => _selectDate(context), // Disable while loading
                      child: Container(
                        width: double.infinity, height: 55 * scaleFactor,
                        padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
                        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(25 * scaleFactor)),
                        child: Align(alignment: Alignment.centerLeft, child: Text(_birthDateDisplay, style: TextStyle(fontSize: 16 * scaleFactor, color: _selectedBirthDate == null ? Colors.grey[600] : Colors.black))),
                      ),
                    ),
                    SizedBox(height: 15 * scaleFactor),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 16 * scaleFactor, color: const Color(0xFFA6A6A6)),
                        children: [
                          const TextSpan(text: '* ', style: TextStyle(color: Colors.red)),
                          const TextSpan(text: 'Do you currently use any substances or medications that can alter your mood, perception, or mental state?'),
                        ],
                      ),
                    ),
                    SizedBox(height: 5 * scaleFactor),
                    Row(children: [
                      _buildSubstanceRadioButton('Yes', scaleFactor),
                      SizedBox(width: 20 * scaleFactor),
                      _buildSubstanceRadioButton('No', scaleFactor),
                    ]),
                    SizedBox(height: 15 * scaleFactor),
                    if (_substanceUse == 'Yes') ...[
                      _buildLabelWithAsterisk('Please specify', scaleFactor),
                      _buildTextField(_specifyController, scaleFactor, hintText: 'e.g., Medication Name, Substance'),
                      SizedBox(height: 15 * scaleFactor),
                    ],
                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor, height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5588A4),
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25 * scaleFactor)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3))
                              : Text('Sign up', style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                     Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : () {
                           Navigator.pushReplacementNamed(context, MyApp.loginRoute);
                        },
                        child: Text(
                          'Already have an account? Log In',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * scaleFactor,
                            color: const Color(0xFF398BB7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Text(text, style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6))),
    );
  }

  Widget _buildLabelWithAsterisk(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Row(children: [
        Text(text, style: TextStyle(fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6))),
        Text(' *', style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor)),
      ]),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    double scaleFactor, {
    bool isPassword = false,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 55 * scaleFactor,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25 * scaleFactor), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor, vertical: (55 * scaleFactor - (16 * scaleFactor * 1.5)) / 2),
          hintStyle: TextStyle(fontSize: 16 * scaleFactor, color: Colors.grey[600]),
        ),
        style: TextStyle(fontSize: 16 * scaleFactor),
      ),
    );
  }

  Widget _buildRadioButton(String value, double scaleFactor) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: value, groupValue: _gender, onChanged: _isLoading ? null : (String? newValue) => setState(() => _gender = newValue), activeColor: const Color(0xFF5588A4), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      InkWell(onTap: _isLoading ? null : () => setState(() => _gender = value), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text(value, style: TextStyle(fontSize: 16 * scaleFactor)))),
    ]);
  }

  Widget _buildSubstanceRadioButton(String value, double scaleFactor) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: value, groupValue: _substanceUse, onChanged: _isLoading ? null : (String? newValue) => setState(() => _substanceUse = newValue), activeColor: const Color(0xFF5588A4), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      InkWell(onTap: _isLoading ? null : () => setState(() => _substanceUse = value), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text(value, style: TextStyle(fontSize: 16 * scaleFactor)))),
    ]);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: const Color(0xFF5588A4), onPrimary: Colors.white, onSurface: Colors.black),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF5588A4))),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      if (mounted) {
        setState(() {
          _selectedBirthDate = picked;
          _birthDateDisplay = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        });
      }
    }
  }
}