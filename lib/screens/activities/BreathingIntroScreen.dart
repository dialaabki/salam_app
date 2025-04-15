// File: lib/screens/activities/breathing_intro_screen.dart

import 'package:flutter/material.dart';
// Removed dart:async as it's not needed here if timer isn't passed to nav bar

// Import the next screen and the shared bottom nav bar widget
import 'BreathingActivityScreen.dart'; // Ensure filename case matches yours
import '../../widgets/bottom_nav_bar.dart'; // Verify this path!

class BreathingIntroScreen extends StatelessWidget {
  // Optional: static const routeName = '/breathingIntro';

  // Add const constructor
  const BreathingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = Color(0xFF1E4B5F);
    final Color startButtonColor = Color(0xFF3E8A9A);
    // Define back button color (can be same as primary text color here)
    final Color backButtonColor = primaryTextColor;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/breathing_bg.png', // Background image
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40), // Add trailing comma
                  Text(
                    'Breathing Activity',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ), // Add trailing comma
                  ), // Add trailing comma
                  SizedBox(height: 25), // Add trailing comma
                  Text(
                    'Breathe in calm, breathe out stress. With every breath, you reconnect to the present moment and the strength within you.',
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryTextColor.withOpacity(0.9),
                      height: 1.5, // Line spacing
                    ), // Add trailing comma
                  ), // Add trailing comma
                  SizedBox(height: 40), // Add trailing comma
                  Center(
                    // Center the "5 deep breaths" text
                    child: Text(
                      '5 deep breaths',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ), // Add trailing comma
                    ), // Add trailing comma
                  ), // Add trailing comma
                  Spacer(), // Push button to bottom - Add trailing comma
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BreathingActivityScreen(),
                          ), // Add trailing comma
                        ); // Add trailing comma
                      }, // Add trailing comma
                      style: ElevatedButton.styleFrom(
                        backgroundColor: startButtonColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 90,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Add trailing comma
                        ), // Add trailing comma
                      ), // Add trailing comma
                      child: Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ), // Add trailing comma
                      ), // Add trailing comma
                    ), // Add trailing comma
                  ), // Add trailing comma
                  SizedBox(
                    height: 20,
                  ), // Space before bottom nav bar - Add trailing comma
                ], // Add trailing comma
              ), // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma
          // Back Button
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                5, // Position below status bar
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, // Or Icons.arrow_back
                color: backButtonColor, // Use defined color
              ), // Add trailing comma
              tooltip: 'Back to Activities',
              onPressed: () {
                Navigator.pop(context); // Add trailing comma
              }, // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma
        ], // Add trailing comma
      ), // Add trailing comma
      // Use the AppBottomNavBar class constructor
      bottomNavigationBar: const AppBottomNavBar(),
    ); // End Scaffold
  }
}
