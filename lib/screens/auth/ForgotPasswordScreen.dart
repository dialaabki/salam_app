import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ForgotPasswordScreen extends StatefulWidget { // Changed to StatefulWidget
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> { // State class
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  bool _isLoading = false; // Loading state

  // Function to handle password reset logic
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email address.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if(mounted) {
       setState(() { _isLoading = true; });
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally pop back to login screen after a delay or immediately
         Navigator.pop(context); // Go back to Login
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
       print("Password Reset Error: ${e.code} - ${e.message}"); // Log for debugging
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
       print("Password Reset Error: $e");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
       }
    } finally {
       if(mounted) {
          setState(() { _isLoading = false; });
       }
    }
  }

  @override
  void dispose() {
    _emailController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const double baseWidth = 375;
    const double baseHeight = 812;

    final widthFactor = screenWidth / baseWidth;
    final heightFactor = screenHeight / baseHeight;
    final scaleFactor = min(widthFactor, heightFactor);

    return Scaffold(
      // Prevent keyboard overflow issues
      resizeToAvoidBottomInset: false, // Can be useful if layout overflows
      body: Stack(
        children: [
          // Blue background
          Container(color: const Color(0xFF276181)),

          // Image at the top (centered)
          Positioned(
            top: 20 * heightFactor,
            left: (screenWidth - 287 * widthFactor) / 2,
            child: Image.asset(
              'assets/images/forgotpasswordpic.png',
              width: 287 * widthFactor, height: 253 * heightFactor, fit: BoxFit.contain,
            ),
          ),

          // White container
          Positioned(
            // Adjust top slightly if needed due to keyboard
            top: (20 + 253) * heightFactor,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only( topLeft: Radius.circular(70), topRight: Radius.circular(70)),
              ),
              // Use SingleChildScrollView ONLY IF content might overflow
              // child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24 * widthFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30 * heightFactor),

                  // Title
                  Padding(
                    padding: EdgeInsets.only(left: 6 * widthFactor),
                    child: Text( 'Forgot Password?', style: TextStyle( fontFamily: 'DavidLibre', fontWeight: FontWeight.bold, fontSize: 40 * scaleFactor, color: const Color(0xFF276181)),),
                  ),
                  SizedBox(height: 20 * heightFactor),

                  // Description
                  Padding(
                    padding: EdgeInsets.only(left: 6 * widthFactor),
                    child: Text( 'No worries, we\'ll send you reset instructions', style: TextStyle( fontFamily: 'Commissioner', fontSize: 16 * scaleFactor, color: const Color(0xFFA6A6A6)),),
                  ),
                  SizedBox(height: 40 * heightFactor),

                  // Email field
                  _buildLabel('Email', widthFactor, heightFactor),
                  _buildTextField( // Pass controller here
                    _emailController, widthFactor, heightFactor,
                  ),
                  SizedBox(height: 55 * heightFactor),

                  // Reset Password button
                  Center(
                    child: SizedBox(
                      width: 195 * widthFactor, height: 55 * heightFactor,
                      child: ElevatedButton(
                        // Call the reset function, disable if loading
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5588A4),
                           disabledBackgroundColor: Colors.grey.shade400, // Feedback when disabled
                          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(25),),
                        ),
                        child: _isLoading
                          ? const SizedBox( // Show loading indicator
                              height: 24, width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Text( // Show button text
                              'Reset Password',
                              style: TextStyle( fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 18 * heightFactor, color: Colors.white,),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30 * heightFactor),

                  // Back to Login link
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : () { // Disable if loading
                        Navigator.pop(context);
                      },
                      child: Text( 'Back to Login', style: TextStyle( fontFamily: 'Commissioner', fontWeight: FontWeight.bold, fontSize: 16 * scaleFactor, color: const Color(0xFF398BB7)),),
                    ),
                  ),
                  SizedBox(height: 20 * heightFactor),
                ],
              ),
             // ), // End SingleChildScrollView if used
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets (Updated _buildTextField to accept controller)
  Widget _buildLabel(String text, double widthFactor, double heightFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * widthFactor, bottom: 5 * heightFactor), // Added bottom padding
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner', fontWeight: FontWeight.bold,
          fontSize: 20 * heightFactor, color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, // Accept controller
    double widthFactor,
    double heightFactor,
  ) {
    // Removed container margin, let padding handle spacing
    return SizedBox( // Use SizedBox for consistent height
      height: 55 * heightFactor, // Match button height? Or keep 50?
      child: TextField(
        controller: controller, // Use passed controller
        keyboardType: TextInputType.emailAddress, // Set keyboard type
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none,),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * widthFactor),
        ),
      ),
    );
  }
}