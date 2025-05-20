// File: lib/screens/auth/DoctorSignUpScreen.dart

import 'dart:math'; // For min function
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // For File object
import 'package:path/path.dart' as path; // For filename

// --- Firebase Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import LoginScreen or route name for navigation
// Assuming main.dart has MyApp class with route constants
import '../../main.dart'; // Adjust path if needed

class DoctorSignUpScreen extends StatefulWidget {
  const DoctorSignUpScreen({super.key});

  @override
  State<DoctorSignUpScreen> createState() => _DoctorSignUpScreenState();
}

class _DoctorSignUpScreenState extends State<DoctorSignUpScreen> {
  // --- Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // Required

  // --- State Variables ---
  String? _gender;
  String _birthDateDisplay = 'DD/MM/YYYY';
  DateTime? _selectedBirthDate;
  String? _selectedDocumentType; // Optional document type
  File? _selectedFile; // Optional file selection
  String? _fileName; // Optional filename
  bool _isLoading = false;

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Password Validation Function (Copied from UserSignUpScreen) ---
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
     if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>_+-=\[\]\\;\''`/~`])').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null; // Password is valid
  }

  // --- Signup Function (Adapted and Corrected) ---
  Future<void> _signUp() async {
    if (!mounted) return;

    // --- 1. Validation ---
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim(); // Get password for validation
    final phone = _phoneController.text.trim();

    // Basic required field validation
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        _gender == null ||
        _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields (*).'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Advanced Password Validation
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

    // Phone length check
    if (phone.length < 9) { // Adjust this length as per your country's standard
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please enter a valid phone number (e.g., 9 digits).'), backgroundColor: Colors.orangeAccent),
       );
       return;
    }

    setState(() { _isLoading = true; });

    String generalErrorMessage = 'An unexpected error occurred during sign up.';

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password, // Use validated password
      );

      User? user = userCredential.user;

      if (user != null) {
        String? documentUrl;
        if (_selectedFile != null && _selectedDocumentType != null) {
          // TODO: Implement actual file upload to Firebase Storage or other service.
          // This would involve uploading _selectedFile and getting the downloadURL.
          // For now, documentUrl will remain null.
          print("Simulating document upload for: $_fileName of type $_selectedDocumentType for user ${user.uid}");
          // Example: documentUrl = await uploadFileAndGetURL(_selectedFile!, user.uid, _fileName);
        }

        await _firestore.collection('doctors').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$firstName $lastName',
          'email': email,
          'phoneNumber': phone,
          'gender': _gender,
          'birthDate': Timestamp.fromDate(_selectedBirthDate!),
          'documentType': _selectedDocumentType,
          'documentUrl': documentUrl,
          'role': 'doctor',
          'isVerified': false, // Email not verified yet
          'accountStatus': 'pending_verification', // Requires email verification and potentially admin approval
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!user.emailVerified) {
          try {
            await user.sendEmailVerification();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Signup successful! Verification email sent. Please check your inbox. Your account also requires admin approval.',
                  ),
                  duration: Duration(seconds: 8),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
             print("Error sending verification email: $e");
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                      content: Text('Signup successful, but failed to send verification email: ${e.toString().replaceFirst("Exception: ", "")}'),
                      backgroundColor: Colors.orange),
                );
             }
          }
        } else if (mounted) { // Should not happen for a brand new user
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup successful! (Email already verified). Account pending admin approval.'), backgroundColor: Colors.green),
           );
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, MyApp.loginRoute); // Navigate to login
        }

      } else {
        generalErrorMessage = 'Signup failed: Could not create user details.';
        throw Exception(generalErrorMessage);
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during signup: CODE='${e.code}' MESSAGE='${e.message}'");
      switch (e.code) {
        case 'weak-password':
        case 'auth/weak-password':
          generalErrorMessage = 'The password provided is too weak. Please ensure it meets all complexity requirements.';
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
          generalErrorMessage = e.message ?? 'Signup failed due to an authentication error (Code: ${e.code}).';
          if (e.code.toLowerCase().contains('internal-error') || e.code.toLowerCase().contains('unknown-error')) {
            generalErrorMessage = 'An internal error occurred during signup. Please try again later.';
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
        String displayError = generalErrorMessage != 'An unexpected error occurred during sign up.'
                              ? generalErrorMessage
                              : e.toString().replaceFirst("Exception: ", "");
        if (e is FirebaseException && generalErrorMessage == 'An unexpected error occurred during sign up.') {
             displayError = e.message ?? "A database error occurred.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $displayError'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _pickFile() async {
     if (_isLoading) return;
     try {
       final result = await FilePicker.platform.pickFiles( type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],);
       if (result != null && result.files.single.path != null) { setState(() { _selectedFile = File(result.files.single.path!); _fileName = path.basename(result.files.single.name); }); }
     } catch (e) { if(mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error picking file: ${e.toString()}')),); } }
  }

  Future<void> _pickImage() async {
     if (_isLoading) return;
     try {
       final pickedFile = await ImagePicker().pickImage( source: ImageSource.gallery, imageQuality: 80,);
       if (pickedFile != null) { setState(() { _selectedFile = File(pickedFile.path); _fileName = path.basename(pickedFile.name); }); }
     } catch (e) { if(mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error picking image: ${e.toString()}'))); } }
  }

   Future<void> _selectDate(BuildContext context) async {
     if (_isLoading) return;
     final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
        firstDate: DateTime(1930),
        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
         builder: (context, child) { return Theme( data: Theme.of(context).copyWith( colorScheme: Theme.of(context).colorScheme.copyWith( primary: const Color(0xFF5588A4), onPrimary: Colors.white, onSurface: Colors.black,), textButtonTheme: TextButtonThemeData( style: TextButton.styleFrom( foregroundColor: const Color(0xFF5588A4)),),), child: child!,);},
      );
      if (picked != null && picked != _selectedBirthDate && mounted) {
        setState(() {
          _selectedBirthDate = picked;
          _birthDateDisplay = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        });
      }
   }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Build Method and UI Helper Widgets ---
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375;

    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Sign Up', style: TextStyle(fontSize: 20 * scaleFactor, color: Colors.white)),
        backgroundColor: const Color(0xFF276181),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF276181)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only( topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric( horizontal: 24 * scaleFactor, vertical: 30 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title moved to AppBar
                    // SizedBox(height: 10 * scaleFactor),

                    Row( children: [
                        Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildLabelWithAsterisk( 'First Name', scaleFactor,), _buildTextField( _firstNameController, scaleFactor,),],),),
                        SizedBox(width: 15 * scaleFactor),
                        Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildLabelWithAsterisk('Last Name', scaleFactor), _buildTextField(_lastNameController, scaleFactor),],),),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabelWithAsterisk('Email', scaleFactor),
                    _buildTextField(_emailController, scaleFactor, keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabelWithAsterisk('Password', scaleFactor),
                    _buildTextField( _passwordController, scaleFactor, isPassword: true,),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabelWithAsterisk('Phone number', scaleFactor),
                    Row( children: [
                        Container( width: 70 * scaleFactor, height: 55 * scaleFactor, decoration: BoxDecoration( color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular( 25 * scaleFactor,),), child: Center( child: Text( '+962', style: TextStyle( fontSize: 16 * scaleFactor, color: Colors.black,),),),),
                        SizedBox(width: 10 * scaleFactor),
                        Expanded( child: _buildTextField(_phoneController, scaleFactor, keyboardType: TextInputType.phone),),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabelWithAsterisk('Gender', scaleFactor),
                    Row( children: [ _buildGenderOption('Male', scaleFactor), SizedBox(width: 20 * scaleFactor), _buildGenderOption('Female', scaleFactor),],),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabelWithAsterisk('Date of birth', scaleFactor),
                    GestureDetector(
                      onTap: _isLoading ? null : () => _selectDate(context),
                      child: Container(
                        width: double.infinity, height: 55 * scaleFactor,
                        padding: EdgeInsets.symmetric( horizontal: 20 * scaleFactor,),
                        decoration: BoxDecoration( color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(25 * scaleFactor),),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text( _birthDateDisplay, style: TextStyle( fontSize: 16 * scaleFactor, color: _selectedBirthDate == null ? Colors.grey[600] : Colors.black,),),
                        ),
                      ),
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    _buildLabel('Upload Document', scaleFactor),
                    Text( 'Proof of license, certifications, or ID (Optional)', style: TextStyle( fontFamily: 'Commissioner', fontSize: 14 * scaleFactor, color: const Color(0xFFA6A6A6),),),
                    SizedBox(height: 10 * scaleFactor),
                    _buildDocumentDropdown(scaleFactor),
                    SizedBox(height: 10 * scaleFactor),
                    _buildUploadButtons(scaleFactor),
                    _buildFilePreview(scaleFactor),
                    SizedBox(height: 30 * scaleFactor),

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
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3,))
                              : Text( 'Sign up', style: TextStyle( fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: Colors.white,),),
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
                    SizedBox(height: 40 * scaleFactor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double scaleFactor) { return Padding( padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor), child: Text( text, style: TextStyle( fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6),),),); }
  Widget _buildLabelWithAsterisk(String text, double scaleFactor) { return Padding( padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor), child: Row( children: [ Text( text, style: TextStyle( fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor, color: const Color(0xFFA6A6A6),),), Text(' *', style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor)),],),); }
  Widget _buildTextField( TextEditingController controller, double scaleFactor, { bool isPassword = false, TextInputType keyboardType = TextInputType.text, String? hintText }) {
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25 * scaleFactor),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20 * scaleFactor,
            // Adjust vertical padding to better center text if needed
            vertical: 15 * scaleFactor, // You might need to fine-tune this
          ),
          hintStyle: TextStyle(fontSize: 16 * scaleFactor, color: Colors.grey[600]),
        ),
        style: TextStyle(fontSize: 16 * scaleFactor),
      ),
    );
  }
  Widget _buildGenderOption(String gender, double scaleFactor) { return Row( mainAxisSize: MainAxisSize.min, children: [ Radio<String>( value: gender, groupValue: _gender, onChanged: _isLoading ? null : (value) { setState(() { _gender = value; }); }, activeColor: const Color(0xFF5588A4), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,), InkWell( onTap: _isLoading ? null : () { setState(() { _gender = gender; }); }, child: Padding( padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text(gender, style: TextStyle(fontSize: 16 * scaleFactor)),),),],); }
  Widget _buildDocumentDropdown(double scaleFactor) { return Container( width: double.infinity, height: 55 * scaleFactor, padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor), decoration: BoxDecoration( color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(25 * scaleFactor),), child: DropdownButtonHideUnderline( child: DropdownButton<String>( value: _selectedDocumentType, hint: Text('Select document type (Optional)', style: TextStyle(fontSize: 16 * scaleFactor, color: Colors.grey[600])), isExpanded: true, style: TextStyle(fontSize: 16 * scaleFactor, color: Colors.black), items: [ 'Medical License', 'Specialty Certification', 'National ID', 'Passport', 'Other Professional Document'].map((String value) { return DropdownMenuItem<String>(value: value, child: Text(value)); }).toList(), onChanged: _isLoading ? null : (newValue) { setState(() { _selectedDocumentType = newValue; }); }, icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]), dropdownColor: Colors.white,),),); }
  Widget _buildUploadButtons(double scaleFactor) { return Row( mainAxisAlignment: MainAxisAlignment.start, children: [ ElevatedButton.icon( onPressed: _isLoading ? null : _pickFile, icon: Icon(Icons.upload_file, size: 20 * scaleFactor), label: Text( 'Upload File', style: TextStyle(fontSize: 14 * scaleFactor),), style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF5588A4).withOpacity(0.9), foregroundColor: Colors.white, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20 * scaleFactor),), padding: EdgeInsets.symmetric( horizontal: 15 * scaleFactor, vertical: 10 * scaleFactor,),),), SizedBox(width: 15 * scaleFactor), ElevatedButton.icon( onPressed: _isLoading ? null : _pickImage, icon: Icon(Icons.camera_alt, size: 20 * scaleFactor), label: Text( 'Use Camera', style: TextStyle(fontSize: 14 * scaleFactor),), style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF6A9FB9), foregroundColor: Colors.white, shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20 * scaleFactor),), padding: EdgeInsets.symmetric( horizontal: 15 * scaleFactor, vertical: 10 * scaleFactor,),),),],); }
  Widget _buildFilePreview(double scaleFactor) { if (_selectedFile == null) return const SizedBox.shrink(); return Padding( padding: EdgeInsets.only(top: 15 * scaleFactor), child: Container( padding: EdgeInsets.all(10 * scaleFactor), decoration: BoxDecoration( color: Colors.grey[200], borderRadius: BorderRadius.circular(10 * scaleFactor), border: Border.all(color: Colors.grey[300]!)), child: Row( children: [ Icon( _fileName != null && _fileName!.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.insert_drive_file, size: 28 * scaleFactor, color: Colors.grey[700],), SizedBox(width: 10 * scaleFactor), Expanded( child: Text( _fileName ?? 'Selected file', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14 * scaleFactor, color: Colors.black87),),), IconButton( icon: Icon(Icons.close, size: 20 * scaleFactor, color: Colors.redAccent), padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: 'Remove file', onPressed: _isLoading ? null : () { setState(() { _selectedFile = null; _fileName = null; }); },),],),),); }
}