import 'dart:math';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  ForgotPasswordScreen({Key? key}) : super(key: key);

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
              'assets/images/forgotpasswordpic.png', // Your forgot password image
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * heightFactor),

                    // "Forgot Password?" title
                    Padding(
                      padding: EdgeInsets.only(left: 6 * widthFactor),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 40 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),

                    SizedBox(height: 20 * heightFactor),

                    // Description text
                    Padding(
                      padding: EdgeInsets.only(left: 6 * widthFactor),
                      child: Text(
                        'No worries, we\'ll send you reset instructions',
                        style: TextStyle(
                          fontFamily: 'Commissioner',
                          fontSize: 16 * scaleFactor,
                          color: const Color(0xFFA6A6A6),
                        ),
                      ),
                    ),

                    SizedBox(height: 40 * heightFactor),

                    // Email field
                    _buildLabel('Email', widthFactor, heightFactor),
                    _buildTextField(_emailController, widthFactor, heightFactor),

                    SizedBox(height: 55 * heightFactor),

                    // Reset Password button
                    Center(
                      child: SizedBox(
                        width: 195 * widthFactor,
                        height: 55 * heightFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle password reset
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5588A4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Reset Password',
                            style: TextStyle(
                              fontFamily: 'Commissioner',
                              fontWeight: FontWeight.bold,
                              fontSize: 18 * heightFactor,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30 * heightFactor),

                    // Back to Login link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * scaleFactor,
                            color: const Color(0xFF398BB7),
                          ),
                        ),
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

  Widget _buildLabel(String text, double widthFactor, double heightFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * widthFactor),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner',
          fontWeight: FontWeight.bold,
          fontSize: 20 * heightFactor,
          color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, double widthFactor, double heightFactor) {
    return Container(
      margin: EdgeInsets.only(left: 20 * widthFactor),
      width: 335 * widthFactor,
      height: 50 * heightFactor,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20 * widthFactor,
          ),
        ),
      ),
    );
  }
}