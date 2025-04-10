import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For checking track date
import 'package:intl/intl.dart'; // For date formatting

// Import screens that UserHomeScreen navigates TO
// No need to import specific screens if using named routes exclusively
// import 'package:salam_app/screens/activities/ActivitySelectionScreen.dart';
// import 'package:salam_app/screens/MoodTrackingScreen.dart';

// --- Import the shared Bottom Nav Bar ---
import 'package:salam_app/widgets/bottom_nav_bar.dart'; // Adjust path if needed

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  // Function to check if mood can be tracked today
  Future<bool> _canTrackMoodToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastTrackDateString = prefs.getString('lastMoodTrackDate');
      final String todayString = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());

      print(
        'Checking Mood Track Date - Last tracked: $lastTrackDateString, Today: $todayString',
      );

      if (lastTrackDateString == null) {
        return true; // Never tracked before
      }
      return lastTrackDateString != todayString;
    } catch (e) {
      print("Error checking mood track date: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salam Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/activitySelection');
              },
              child: Text('Go to Activities'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool canTrack = await _canTrackMoodToday();
                if (!context.mounted) return;
                if (canTrack) {
                  Navigator.pushNamed(context, '/moodTracking');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You have already tracked your mood today.',
                      ),
                      backgroundColor: Colors.blueGrey,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Track Your Mood'),
            ),
            SizedBox(height: 20), // Space before new button
            // --- ADDED BUTTON FOR RESOURCES ---
            ElevatedButton(
              onPressed: () {
                // Navigate to the Resources screen using its named route
                Navigator.pushNamed(context, '/resources');
              },
              child: Text('Go to Resources'),
            ),
            // --- END OF ADDED BUTTON ---

            // Example for Reminders (ensure '/reminders' route exists)
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reminders');
              },
              child: Text('Go to Reminders'),
            ),
          ],
        ),
      ),
      // --- USE THE SHARED BOTTOM NAV BAR ---
      // Add const if AppBottomNavBar constructor is const and takes no parameters
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
