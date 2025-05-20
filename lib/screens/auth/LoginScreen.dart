// File: lib/screens/auth/loginScreen.dart

import 'dart:math'; // For min function
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import main.dart for route constants
import '../../main.dart'; // Assuming main.dart is two levels up from 'lib/screens/auth/'

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loginUser() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    // Default error, will be updated by specific catches
    String errorMessageToShow = 'An unexpected error occurred. Please try again.';

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.reload();
        user = _auth.currentUser; // Re-fetch the user to get the latest state

        if (user == null) {
          errorMessageToShow = "Login successful, but user details could not be fetched. Please try again.";
          throw Exception(errorMessageToShow);
        }

        if (!user.emailVerified) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified. Please check your inbox and click the verification link.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          await _auth.signOut();
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        String? role;
        Map<String, dynamic>? userData;

        DocumentSnapshot patientDoc = await _firestore.collection('users').doc(user.uid).get();
        if (patientDoc.exists) {
          userData = patientDoc.data() as Map<String, dynamic>?;
          role = userData?['role'] as String? ?? 'user';
          print("User role found in 'users' collection: $role");
        } else {
          DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(user.uid).get();
          if (doctorDoc.exists) {
            userData = doctorDoc.data() as Map<String, dynamic>?;
            role = userData?['role'] as String? ?? 'doctor';
            print("User role found in 'doctors' collection: $role");
          }
        }

        if (role == null || userData == null) {
          print("Error: User authenticated (${user.uid}) but no profile found in 'users' or 'doctors' collection.");
          errorMessageToShow = "Profile data missing. Please contact support or try signing up again.";
          throw Exception(errorMessageToShow);
        }

        if (role == 'doctor') {
          String accountStatus = userData['accountStatus'] as String? ?? 'unknown';
          print("Doctor account status: $accountStatus");
          if (accountStatus != 'active') {
            await _auth.signOut();
            if (!mounted) return;
            String statusMessage;
            if (accountStatus == 'pending_verification') {
              statusMessage = 'Your doctor account requires email verification. Please check your inbox.';
            } else if (accountStatus == 'pending_document' || accountStatus == 'pending') {
              statusMessage = 'Your doctor account is pending ($accountStatus). Please wait for approval or complete necessary steps.';
            } else if (accountStatus == 'suspended') {
              statusMessage = 'Your doctor account has been suspended. Please contact support.';
            } else {
              statusMessage = 'Your doctor account is currently inactive ($accountStatus). Please contact support.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(statusMessage), backgroundColor: Colors.orange, duration: const Duration(seconds: 5)),
            );
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }

        if (!mounted) return;
        if (role == 'doctor') {
          print("Navigating to Doctor Home");
          Navigator.pushReplacementNamed(context, MyApp.doctorHomeRoute);
        } else {
          print("Navigating to Patient Home");
          Navigator.pushReplacementNamed(context, MyApp.userHomeRoute);
        }
      } else {
        // This case should ideally not be reached if signInWithEmailAndPassword succeeds.
        // If user is null after a successful call, it's an unexpected state.
        errorMessageToShow = 'Login failed: Unable to retrieve user details after sign-in attempt.';
        throw Exception(errorMessageToShow);
      }
    } on FirebaseAuthException catch (e) {
      // Log the actual code and message for debugging
      print("FirebaseAuthException during login: CODE='${e.code}' MESSAGE='${e.message}'");
      
      // errorMessageToShow is already initialized outside the try block.
      // We will assign to it based on e.code.

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password': // More common in older Firebase SDKs
        case 'invalid-credential': // Preferred in newer SDKs, covers wrong password and user-not-found
        case 'unknown-error': 
             print("FirebaseAuthException: Caught '${e.code}', treating as incorrect credentials.");
             errorMessageToShow = 'Incorrect email or password. Please try again.';
          break;

        // **IMPORTANT**: Check your debug console for the exact error code
        // when you enter a WRONG PASSWORD. If it's 'auth/internal-error' or something else,
        // add a specific case for it here to show 'Incorrect email or password.'
        // For example, if Firebase returns 'auth/internal-error' for a wrong password:
        case 'auth/internal-error': 
             print("FirebaseAuthException: Caught '${e.code}', specifically treating as incorrect credentials based on observed behavior.");
             errorMessageToShow = 'Incorrect email or password. Please try again.';
             break;
        // If you see another code like 'ERROR_WRONG_PASSWORD' or similar for wrong password,
        // add a case for that instead of or in addition to 'auth/internal-error':
        // case 'ERROR_WRONG_PASSWORD':
        //   errorMessageToShow = 'Incorrect email or password. Please try again.';
        //   break;

        case 'invalid-email':
        case 'auth/invalid-email':
          errorMessageToShow = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
        case 'auth/user-disabled':
          errorMessageToShow = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
        case 'auth/too-many-requests':
          errorMessageToShow = 'Too many login attempts. Please try again later or reset your password.';
          break;
        case 'network-request-failed':
        case 'auth/network-request-failed':
          errorMessageToShow = 'Network error. Please check your internet connection and try again.';
          break;
        default:
          // This block is reached if the error code wasn't specifically handled above.
          // If 'auth/internal-error' was specifically for wrong password and handled by a case above,
          // then an 'auth/internal-error' reaching here means a *different* kind of internal error.
          if (e.code.toLowerCase().contains('internal-error') || 
              e.code.toLowerCase().contains('unknown-error')) {
            // This is for genuine internal/unknown errors not otherwise classified.
            print("FirebaseAuthException: Caught unhandled internal/unknown error: ${e.code}");
            errorMessageToShow = 'An internal server error occurred. Please try again in a few moments. (Code: ${e.code})';
          } else {
            // For any other Firebase Auth specific error, try to use its message, or a generic one.
            errorMessageToShow = e.message ?? 'An authentication error occurred. (Code: ${e.code})';
          }
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessageToShow), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      print("General Login Error: $e");
      if (mounted) {
        String displayErrorFromCatch = e.toString().replaceFirst("Exception: ", "");
        
        // If errorMessageToShow was set by FirebaseAuthException to something specific,
        // or if the general exception 'e' contains a message that was previously set as errorMessageToShow (custom throw),
        // prioritize that.
        if (errorMessageToShow != 'An unexpected error occurred. Please try again.' || e.toString().contains(errorMessageToShow)) {
            // errorMessageToShow is likely already specific (from FirebaseAuthException or custom throw)
            // No change needed, it will be used.
        } else {
            // If errorMessageToShow is still the generic one, use the message from the current general 'e'
            errorMessageToShow = displayErrorFromCatch;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessageToShow.isNotEmpty ? errorMessageToShow : "An error occurred."), backgroundColor: Colors.red),
        );
      }
      // Ensure user is signed out if any error occurs post-auth attempt or during profile fetch
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToUserSignUp() {
    Navigator.pushNamed(context, MyApp.userSignupRoute);
  }

  void _navigateToDoctorSignUp() {
     Navigator.pushNamed(context, MyApp.doctorSignupRoute);
  }

  void _navigateToForgotPassword() {
     Navigator.pushNamed(context, MyApp.forgotPasswordRoute);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseWidth = 375.0;
    final baseHeight = 812.0;
    final scaleFactor = min(screenWidth / baseWidth, screenHeight / baseHeight);

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Container(color: const Color(0xFF276181)),
          Positioned(
            top: screenHeight * 0.05, 
            left: 0,
            right: 0, 
            child: Align( 
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/loginpic.png', 
                width: screenWidth * 0.75, 
                fit: BoxFit.contain,
                 errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported, size: 100, color: Colors.white54),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4, 
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
                    horizontal: 24 * scaleFactor, vertical: 30 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 6 * scaleFactor),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontFamily: 'DavidLibre', 
                          fontWeight: FontWeight.bold,
                          fontSize: 48 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),
                    SizedBox(height: 35 * scaleFactor),
                    _buildLabel('Email', scaleFactor),
                    _buildTextField(
                      _emailController,
                      scaleFactor,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 25 * scaleFactor),
                    _buildLabel('Password', scaleFactor),
                    _buildTextField(
                      _passwordController,
                      scaleFactor,
                      obscureText: true,
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _navigateToForgotPassword,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4)),
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontFamily: 'Commissioner', 
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * scaleFactor,
                            color: const Color(0xFFA79D9D),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25 * scaleFactor),
                    _buildLoginButton(scaleFactor),
                    SizedBox(height: 30 * scaleFactor),
                    _buildSignupText(scaleFactor),
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
      padding: EdgeInsets.only(
        left: 8 * scaleFactor,
        bottom: 5 * scaleFactor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner',
          fontWeight: FontWeight.bold,
          fontSize: 20 * scaleFactor,
          color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    double scaleFactor, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 55 * scaleFactor, 
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25 * scaleFactor),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor, vertical: 15 * scaleFactor),
        ),
        style: TextStyle(fontSize: 16 * scaleFactor), 
      ),
    );
  }

  Widget _buildLoginButton(double scaleFactor) {
    return Center(
      child: SizedBox(
        width: 195 * scaleFactor,
        height: 55 * scaleFactor,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5588A4),
            disabledBackgroundColor: Colors.grey.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25 * scaleFactor),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Log in',
                  style: TextStyle(
                    fontFamily: 'Commissioner',
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * scaleFactor,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignupText(double scaleFactor) {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontWeight: FontWeight.bold,
            fontSize: 12 * scaleFactor,
            color: const Color(0xFFA79D9D),
          ),
        ),
        SizedBox(height: 5 * scaleFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _isLoading ? null : _navigateToUserSignUp,
              child: Text(
                'Sign Up as User',
                style: TextStyle(
                  fontFamily: 'Commissioner',
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * scaleFactor,
                  color: const Color(0xFF398BB7),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor),
              child: Text(
                "or",
                style: TextStyle(
                  fontSize: 12 * scaleFactor,
                  color: const Color(0xFFA79D9D),
                ),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _navigateToDoctorSignUp,
              child: Text(
                'Sign Up as Doctor',
                style: TextStyle(
                  fontFamily: 'Commissioner',
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * scaleFactor,
                  color: const Color(0xFF398BB7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}