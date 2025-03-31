import 'package:flutter/material.dart';

class ThankScreen extends StatelessWidget {
  const ThankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base width for scaling

    return Scaffold(
      body: Stack(
        children: [
          // Blue background
          Container(color: const Color(0xFF276181)),

          // Image at the top (centered)
          Positioned(
            top: 50 * scaleFactor,
            left: (screenWidth - 200 * scaleFactor) / 2,
            child: Image.asset(
              'assets/images/Thankpic.png',
              width: 200 * scaleFactor,
              height: 200 * scaleFactor,
              fit: BoxFit.contain,
            ),
          ),

          // White container with rounded top corners
          Positioned(
            top: 250 * scaleFactor,
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
                  vertical: 30 * scaleFactor,
                ),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'Thank You for',
                      style: TextStyle(
                        fontFamily: 'DavidLibre',
                        fontWeight: FontWeight.bold,
                        fontSize: 32 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    Text(
                      'Signing Up!',
                      style: TextStyle(
                        fontFamily: 'DavidLibre',
                        fontWeight: FontWeight.bold,
                        fontSize: 32 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // Success message
                    Text(
                      'Your application has been submitted successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontSize: 18 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // Verification message
                    Text(
                      'We are reviewing your\n'
                      'information to verify\n'
                      'your credentials. You will\n'
                      'receive an email as soon\n'
                      'as your account is\n'
                      'approved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontSize: 16 * scaleFactor,
                        color: const Color(0xFFA6A6A6),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 50 * scaleFactor),

                    // Back to Login button
                    SizedBox(
                      width: 195 * scaleFactor,
                      height: 63 * scaleFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5588A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              25 * scaleFactor,
                            ),
                          ),
                        ),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 20 * scaleFactor,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
