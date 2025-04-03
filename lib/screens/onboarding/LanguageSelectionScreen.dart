import 'dart:math';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = min(screenWidth / 375, screenHeight / 812);

    return Scaffold(
      body: Stack(
        children: [
          // White background (main)
          Container(color: Colors.white),

          // Blue header with title only
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140 * scaleFactor,
            child: Container(
              color: const Color(0xFF276181),
              child: Center(
                child: Text(
                  'Salam',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay', // Changed font
                    fontWeight: FontWeight.bold,
                    fontSize: 36 * scaleFactor,
                    color: Colors.white,
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
                  children: [
                    SizedBox(height: 40 * scaleFactor),
                    Text(
                      'Helping you thrive, not just survive.',
                      style: TextStyle(
                        fontFamily: 'Montserrat', // Changed font
                        fontSize: 18 * scaleFactor,
                        color: const Color(0xFF276181), // Your blue color
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30 * scaleFactor),
                      child: Image.asset(
                        'assets/images/languagepic.png',
                        width: 300 * scaleFactor,
                        height: 300 * scaleFactor,
                        fit: BoxFit.contain,
                      ),
                    ),

                    Text(
                      'Choose a language to make the app yours!',
                      style: TextStyle(
                        fontFamily: 'Montserrat', // Changed font
                        fontSize: 16 * scaleFactor,
                        color: const Color(0xFF276181), // Your blue color
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),
                    _buildLanguageButton('ENGLISH', scaleFactor),
                    SizedBox(height: 20 * scaleFactor),
                    _buildLanguageButton('ARABIC', scaleFactor),
                    SizedBox(height: 40 * scaleFactor),
                    Text(
                      'Start your Journey!',
                      style: TextStyle(
                        fontFamily: 'Montserrat', // Changed font
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * scaleFactor,
                        color: const Color(0xFF276181),
                      ), // Your blue color
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String text, double scaleFactor) {
    return SizedBox(
      width: 250 * scaleFactor,
      height: 60 * scaleFactor,
      child: ElevatedButton(
        onPressed: () {},
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
