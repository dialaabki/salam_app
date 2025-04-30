// File: lib/screens/onboarding/LanguageSelectionScreen.dart

import 'dart:math'; // For min()
import 'package:flutter/material.dart';
// *** CORRECT: Import the Signup Screen ***
import '../auth/signupScreen.dart'; // Make sure this path is correct for your project structure

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Basic scaling factor
    final scaleFactor = min(screenWidth / 375, screenHeight / 812);

    return Scaffold(
      body: Stack(
        children: [
          // White background (main)
          Container(color: Colors.white),

          // Blue header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140 * scaleFactor,
            child: Container(
              color: const Color(0xFF276181),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top / 2),
                  child: Text(
                    'Salam',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.bold,
                      fontSize: 36 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // White content container
          Positioned(
            top: 100 * scaleFactor,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24 * scaleFactor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40 * scaleFactor),
                    Text(
                      'Helping you thrive, not just survive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30 * scaleFactor),
                      child: Image.asset(
                        'assets/images/languagepic.png',
                        width: min(300 * scaleFactor, screenWidth * 0.7),
                        height: min(300 * scaleFactor, screenHeight * 0.35),
                        fit: BoxFit.contain,
                      ),
                    ),

                    Text(
                      'Choose a language to make the app yours!',
                       textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // --- Pass context to the button builder ---
                    _buildLanguageButton(context, 'ENGLISH', scaleFactor),

                    SizedBox(height: 20 * scaleFactor),

                    // --- Pass context to the button builder ---
                    _buildLanguageButton(context, 'ARABIC', scaleFactor),

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

  // --- Button builder method ---
  Widget _buildLanguageButton(BuildContext context, String text, double scaleFactor) {
    return SizedBox(
      width: 250 * scaleFactor,
      height: 60 * scaleFactor,
      child: ElevatedButton(
        // *** CORRECT: Navigation logic is here ***
        onPressed: () {
          // TODO: Add logic here to actually SET the chosen language preference if needed
          print('Selected Language: $text'); // Optional: for debugging

          // *** CORRECT: Navigate to signupScreen ***
          Navigator.of(context).pushReplacement( // Use pushReplacement so user can't go back
            MaterialPageRoute(builder: (context) => const SignupScreen()), // Ensure 'signupScreen' class name matches exactly
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5588A4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30 * scaleFactor),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontWeight: FontWeight.bold,
            fontSize: 20 * scaleFactor,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}