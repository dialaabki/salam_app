// File: lib/screens/activities/breathing_completion_screen.dart

import 'package:flutter/material.dart';
// Removed dart:async as it's not needed here if timer isn't passed to nav bar

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed
// Import the ActivitySelectionScreen if navigating back specifically to it by name
// import 'ActivitySelectionScreen.dart'; // Assuming filename matches class name

class BreathingCompletionScreen extends StatelessWidget {
  // Optional: Add static const routeName = '/breathingCompletion';

  // Add const constructor
  const BreathingCompletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = Color(0xFF1E4B5F);
    final Color finishButtonColor = Color(0xFF3E8A9A);
    // Use primary text color for back button for contrast
    final Color backButtonColor = primaryTextColor;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/breathing_bg.png', // Common background
              fit: BoxFit.cover,
            ), // Add trailing comma
          ), // Add trailing comma
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Spacer(flex: 2), // Space above content - Add trailing comma
                  Text( // Completion message
                    'Breathe in peace,\nbreathe out stress.\nYou\'re doing amazing!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                      height: 1.5, // Line spacing
                    ), // Add trailing comma
                  ), // Add trailing comma
                  SizedBox(height: 40), // Space before image - Add trailing comma
                  Image.asset( // Completion image
                    'assets/images/lungs_complete.png',
                    height: MediaQuery.of(context).size.height * 0.25, // Adjust size
                  ), // Add trailing comma
                  Spacer(flex: 3), // Push button down - Add trailing comma
                  ElevatedButton( // Finish button
                    onPressed: () {
                      // Navigate back to the very first screen (e.g., home)
                      Navigator.popUntil(context, (route) => route.isFirst);
                      // Or navigate specifically to Activity Selection if needed and routes are set up:
                      // Navigator.pushNamedAndRemoveUntil(context, ActivitySelectionScreen.routeName, (route) => route.isFirst);
                    }, // Add trailing comma
                    style: ElevatedButton.styleFrom(
                      backgroundColor: finishButtonColor,
                      padding: EdgeInsets.symmetric(horizontal: 90, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Add trailing comma
                      ), // Add trailing comma
                    ), // Add trailing comma
                    child: Text(
                      'Finish',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold), // Add trailing comma
                    ), // Add trailing comma
                  ), // Add trailing comma
                   Spacer(flex: 1), // Space below button - Add trailing comma
                ], // Add trailing comma
              ), // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma

          // --- ADDED Back Button ---
          // This back button provides an alternative way to exit besides "Finish"
          // It likely goes back to the previous screen (which SHOULD be the activity selection screen if that's how you navigated here)
          Positioned(
            top: MediaQuery.of(context).padding.top + 5, // Position below status bar
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, // Or Icons.arrow_back
                color: backButtonColor, // Use defined color
              ), // Add trailing comma
              tooltip: 'Back to Activities', // Tooltip for accessibility
              onPressed: () {
                // Option 1: Simple pop (goes to the screen that opened this one)
                Navigator.pop(context);

                // Option 2: If you ALWAYS want to ensure it goes to ActivitySelectionScreen
                // and clear anything above it (requires named routes setup):
                // Navigator.popUntil(context, ModalRoute.withName(ActivitySelectionScreen.routeName));

                // Option 3: Go all the way home (same as Finish button)
                // Navigator.popUntil(context, (route) => route.isFirst);
              }, // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma
          // --- END Back Button ---

        ], // Add trailing comma
      ), // Add trailing comma
      // --- FIXED Bottom Nav Bar Call ---
      // Use the AppBottomNavBar class constructor
      bottomNavigationBar: const AppBottomNavBar(), // Add trailing comma
      // --- END FIX ---
    ); // End Scaffold
  }
}