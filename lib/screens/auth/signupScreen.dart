import 'dart:math';
import 'package:flutter/material.dart';

// --- ADD IMPORTS for the specific signup screens ---
import 'UserSignUpScreen.dart'; // Import the User sign up screen
import 'DoctorSignUpScreen.dart'; // Import the Doctor sign up screen

class SignupScreen extends StatelessWidget {
  // --- Ensure this class name matches the file name (if it was lowercase 's' before) ---
  // If your actual class name IS 'signupScreen', keep it lowercase here.
  // But convention is UpperCamelCase 'SignupScreen'.

  const SignupScreen({
    super.key,
  }); // Use standard convention if class name is SignupScreen

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Base dimensions (for an average iPhone 11/12/13/14/15 size reference)
    const double baseWidth = 375;
    const double baseHeight = 812;

    final widthFactor = screenWidth / baseWidth;
    final heightFactor = screenHeight / baseHeight;
    final scaleFactor = min(widthFactor, heightFactor);

    return Scaffold(
      body: Stack(
        children: [
          // Blue background
          Container(color: const Color(0xFF276181)),

          // Image at the top (centered)
          Positioned(
            top: 20 * heightFactor,
            left: (screenWidth - 287 * widthFactor) / 2,
            child: Image.asset(
              'assets/images/signupaspic.png', // Change to your signup image
              width: 287 * widthFactor,
              height: 253 * heightFactor,
              fit: BoxFit.contain,
            ),
          ),

          // White container with rounded top corners
          Positioned(
            top: (20 + 253) * heightFactor,
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
                padding: EdgeInsets.symmetric(horizontal: 24 * widthFactor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30 * heightFactor),

                    // "Sign up as a" text
                    Text(
                      'Sign up as a',
                      style: TextStyle(
                        fontFamily: 'DavidLibre',
                        fontWeight: FontWeight.bold,
                        fontSize: 40 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),

                    SizedBox(height: 40 * heightFactor),

                    // User button
                    _buildRoleButton(
                      'User',
                      widthFactor,
                      heightFactor,
                      onPressed: () {
                        // --- NAVIGATE TO USER SIGN UP SCREEN ---
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // Ensure the class name 'UserSignUpScreen' is correct
                            builder: (context) => const UserSignUpScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 30 * heightFactor),

                    // Doctor button
                    _buildRoleButton(
                      'Doctor',
                      widthFactor,
                      heightFactor,
                      onPressed: () {
                        // --- NAVIGATE TO DOCTOR SIGN UP SCREEN ---
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // Ensure the class name 'DoctorSignUpScreen' is correct
                            builder: (context) => const DoctorSignUpScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 60 * heightFactor),

                    // Bottom text
                    Text(
                      'To get everything ready\nfor you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontSize: 20 * scaleFactor,
                        color: const Color(0xFFA6A6A6),
                      ),
                    ),

                    SizedBox(height: 20 * heightFactor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    String text,
    double widthFactor,
    double heightFactor, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250 * widthFactor,
      height: 80 * heightFactor,
      child: ElevatedButton(
        onPressed: onPressed, // The navigation logic is passed here
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5588A4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25 * widthFactor),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontWeight: FontWeight.bold,
            fontSize: 30 * widthFactor,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
