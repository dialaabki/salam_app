import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For checking track date
import 'package:intl/intl.dart';                         // For date formatting

// Ensure these import paths are correct for YOUR project structure
import 'package:salam_app/screens/activities/ActivitySelectionScreen.dart';
import 'package:salam_app/screens/MoodTrackingScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salam App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
         textTheme: TextTheme(
             // Define text styles if needed globally
         ),
         iconTheme: IconThemeData(
             // Define icon themes if needed globally
         )
      ),
      initialRoute: '/', // Starting point
      routes: {
        '/': (context) => HomeScreen(),
        '/activitySelection': (context) => ActivitySelectionScreen(),
        '/moodTracking': (context) => MoodTrackingScreen(),
      },
    );
  }
}

// Home Screen with buttons and mood tracking check logic
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Function to check if mood can be tracked today
  Future<bool> _canTrackMoodToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use a key to store the last tracked date string
      final String? lastTrackDateString = prefs.getString('lastMoodTrackDate');
      final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

      print('Checking Mood Track Date - Last tracked: $lastTrackDateString, Today: $todayString');

      if (lastTrackDateString == null) {
        return true; // Never tracked before
      }
      // Allow tracking if the last tracked date is NOT the same as today's date
      return lastTrackDateString != todayString;
    } catch (e) {
      print("Error checking mood track date: $e");
      // Allow tracking by default if there's an error reading preferences,
      // to avoid blocking the user unnecessarily. Consider logging this error.
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
                // Navigate to the Activity Selection Screen
                Navigator.pushNamed(context, '/activitySelection');
              },
              child: Text('Go to Activities'),
            ),
            SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () async { // Make onPressed async to use await
                bool canTrack = await _canTrackMoodToday(); // Check if tracking is allowed

                // IMPORTANT: Check if the widget is still mounted after the await call
                if (!context.mounted) return;

                if (canTrack) {
                  // Navigate to the Mood Tracking Screen if allowed
                  Navigator.pushNamed(context, '/moodTracking');
                } else {
                  // Show a message if already tracked today
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You have already tracked your mood today.'),
                      backgroundColor: Colors.blueGrey, // Optional: customize snackbar
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Track Your Mood'), // Button for mood tracking
            ),
          ],
        ),
      ),
      // If you have a bottom nav bar, add it here:
      // bottomNavigationBar: BottomNavBar(), // Example
    );
  }
}
