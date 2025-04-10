import 'package:flutter/material.dart';

// Import your screen files
import 'screens/Doctor/homeScreen.dart';
import 'screens/Doctor/patientsScreen.dart';
import 'screens/Doctor/notesScreen.dart';
import 'screens/Doctor/profileScreen.dart';
import 'screens/Doctor/settingsScreen.dart';
import 'screens/Doctor/notificationsScreen.dart';
// Import PatientDetailScreen if you want a named route for it,
// otherwise, use MaterialPageRoute as implemented in HomeScreen/PatientsScreen.
// import 'patient_detail_screen.dart';

// Global Theme Notifier (as used in SettingsScreen)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the themeNotifier for theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Doctor App',
          theme: ThemeData.light(useMaterial3: false), // Your light theme
          darkTheme: ThemeData.dark(useMaterial3: false), // Your dark theme
          themeMode: currentMode, // Use the notifier's value
          debugShowCheckedModeBanner: false,

          // Define named routes for easy navigation
          initialRoute: '/', // Start with the HomeScreen
          routes: {
            '/': (context) => const HomeScreen(),
            '/patients': (context) => const PatientsScreen(),
            '/notes': (context) => const NotesScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings':
                (context) =>
                    const SettingsScreen(), // Accessed via Drawer/Profile
            '/notifications':
                (context) => const NotificationsScreen(), // Accessed via Drawer
            // You could add a route for PatientDetailScreen if needed,
            // but passing arguments via MaterialPageRoute is often easier.
            // '/patientDetail': (context) => PatientDetailScreen(patient: ModalRoute.of(context)!.settings.arguments as Patient),
          },
        );
      },
    );
  }
}
