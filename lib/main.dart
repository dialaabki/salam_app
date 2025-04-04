import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For checking track date
import 'package:intl/intl.dart'; // For date formatting

// Ensure these import paths are correct for YOUR project structure
// --- REMOVED ActivitySelectionScreen import if not used elsewhere ---
// import 'package:salam_app/screens/activities/ActivitySelectionScreen.dart';
import 'package:salam_app/screens/MoodTrackingScreen.dart';
// --- ADDED import for the new RemindersListScreen ---
import 'package:salam_app/screens/Reminders/remindersListScreen.dart'; // Adjust path if needed

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
        primarySwatch: Colors.teal, // Changed to teal to match example theme
        // Define text styles if needed globally
        // Define icon themes if needed globally
        // Use teal or another color that fits the design
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
            .copyWith(secondary: Colors.amberAccent),
      ),
      initialRoute: '/', // Starting point
      routes: {
        '/': (context) => HomeScreen(),
        // '/activitySelection': (context) => ActivitySelectionScreen(), // Keep if needed elsewhere, remove if not
        '/moodTracking': (context) => MoodTrackingScreen(),
        // --- ADDED route for the Reminders List Screen ---
        '/remindersList': (context) => RemindersListScreen(),
      },
    );
  }
}

// Home Screen with buttons and mood tracking check logic
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Function to check if mood can be tracked today (keep as is)
  Future<bool> _canTrackMoodToday() async {
    // ... (your existing logic)
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastTrackDateString = prefs.getString('lastMoodTrackDate');
      final String todayString =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (lastTrackDateString == null) return true;
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
                // --- UPDATED Navigation ---
                // Navigate to the Reminders List Screen
                Navigator.pushNamed(
                    context, '/remindersList'); // Use the new route name
              },
              // --- Optional: Update Button Text ---
              child: Text(
                  'Go to Reminders'), // Changed text to reflect destination
            ),
            SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () async {
                // Keep mood tracking logic as is
                bool canTrack = await _canTrackMoodToday();
                if (!context.mounted) return;
                if (canTrack) {
                  Navigator.pushNamed(context, '/moodTracking');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('You have already tracked your mood today.'),
                      backgroundColor: Colors.blueGrey,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Track Your Mood'),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavBar(), // Example
    );
  }
}
