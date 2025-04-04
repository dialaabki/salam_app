import 'package:flutter/material.dart';

// --- Import Screens ---
import 'package:salam_app/screens/UserHomeScreen.dart';
import 'package:salam_app/screens/activities/ActivitySelectionScreen.dart';
import 'package:salam_app/screens/MoodTrackingScreen.dart';
// --- ADDED: Import Resources Screen ---
import 'package:salam_app/screens/resources/ResourcesListScreen.dart';
// --- ADDED: Import Reminders Screen (if you have it) ---
// Import Profile Screen placeholder or actual screen
// import 'package:salam_app/screens/profile_screen.dart';


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
         textTheme: TextTheme(),
         iconTheme: IconThemeData()
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => UserHomeScreen(),
        '/activitySelection': (context) => ActivitySelectionScreen(),
        '/moodTracking': (context) => MoodTrackingScreen(),
        // --- ADDED: Route for Resources Screen ---
        '/resources': (context) => ResourcesListScreen(),
        // --- ADDED: Route for Reminders Screen ---
        // Make sure RemindersListScreen exists at the specified path
        '/reminders': (context) => UserHomeScreen(),
        // --- ADDED: Placeholder Route for Profile Screen ---
        // Replace with your actual ProfileScreen when ready
        '/profile': (context) => Scaffold(appBar: AppBar(title: Text('Profile')), body: Center(child: Text('Profile Screen Placeholder'))),

        // TODO: Add routes for reminder detail/add screens, quiz, video player if needed via named routes
      },
    );
  }
}