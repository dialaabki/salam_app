import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// --- Firebase Imports ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- Import Screens ---
// User/Patient Screens
import 'screens/UserHomeScreen.dart';
import 'screens/progress/UserProgressHistoryScreen.dart';
import 'screens/notifications/UserNotificationsScreen.dart';
import 'screens/settings/UserSettingsScreen.dart';
import 'screens/profile/UserProfileScreen.dart';
import 'screens/Reminders/RemindersListScreen.dart';
import 'screens/MoodTrackingScreen.dart';
import 'screens/SelfAssessment/SelfAssessmentScreen.dart';
import 'screens/activities/ActivitySelectionScreen.dart';
import 'screens/resources/ResourcesListScreen.dart';
import 'screens/DoctorDirectory/DoctorDirectoryScreen.dart';

// Doctor Screens
import 'screens/Doctor/DoctorHomeScreen.dart';
// --- ADD IMPORTS FOR NEW DOCTOR SCREENS ---
import 'screens/Doctor/patientsScreen.dart'; // Ensure this file exists and contains PatientsScreen class
import 'screens/Doctor/NotesScreen.dart';   // Ensure this file exists and contains NotesScreen class
// You might also need ProfileScreen and SettingsScreen for the doctor if they are distinct
import 'screens/Doctor/ProfileScreen.dart'; // Assuming this is the Doctor's profile
import 'screens/Doctor/SettingsScreen.dart'; // Assuming this is the Doctor's settings

// Onboarding/Auth Screens
import 'screens/onboarding/LanguageSelectionScreen.dart';
import 'screens/auth/loginScreen.dart';
import 'screens/auth/UserSignUpScreen.dart';
import 'screens/auth/DoctorSignUpScreen.dart';
import 'screens/auth/ForgotPasswordScreen.dart';
// import 'screens/auth/AccountVerificationScreen.dart';

// --- Import ThemeNotifier ---
import 'providers/theme_provider.dart'; // Ensure this path is correct and ThemeNotifier is defined

// --- Main Function ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Ensure ThemeNotifier is correctly defined
      child: const MyApp(),
    ),
  );
}

// --- MyApp Widget ---
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // --- Define Route Name Constants ---
  // Onboarding & Auth
  static const String languageSelectionRoute = '/language-selection';
  static const String loginRoute = '/login';
  static const String userSignupRoute = '/user_signup';
  static const String doctorSignupRoute = '/doctor_signup';
  static const String forgotPasswordRoute = '/forgot_password';
  // static const String verifyEmailRoute = '/verify_email';

  // User/Patient Routes
  static const String userHomeRoute = '/'; // Often home is just '/'
  static const String userProgressRoute = '/user/progress';
  static const String userNotificationsRoute = '/user/notifications';
  static const String userSettingsRoute = '/user/settings';
  static const String userProfileRoute = '/user/profile';
  static const String remindersRoute = '/reminders';
  static const String moodTrackingRoute = '/moodTracking';
  static const String selfAssessmentRoute = '/selfAssessment';
  static const String activitySelectionRoute = '/activitySelection';
  static const String resourcesRoute = '/resources';
  static const String doctorsRoute = '/doctors';

  // Doctor Routes
  static const String doctorHomeRoute = '/doctor_home';
  // --- ADDED DOCTOR ROUTE CONSTANTS ---
  static const String doctorPatientsRoute = '/doctor/patients'; // Unique name
  static const String doctorNotesRoute = '/doctor/notes';       // Unique name
  static const String doctorProfileRoute = '/doctor/profile';   // For doctor's own profile
  static const String doctorSettingsRoute = '/doctor/settings'; // For doctor's settings

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier provided above
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Mind Care App',
      theme: themeNotifier.lightTheme, // Use theme from provider
      darkTheme: themeNotifier.darkTheme, // Use theme from provider
      themeMode: themeNotifier.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        // Locale('ar', ''),
      ],
      initialRoute: languageSelectionRoute, // Or your preferred initial route

      routes: {
        // Onboarding & Auth
        languageSelectionRoute: (context) => const LanguageSelectionScreen(),
        loginRoute: (context) => const LoginScreen(),
        userSignupRoute: (context) => const UserSignUpScreen(),
        doctorSignupRoute: (context) => const DoctorSignUpScreen(),
        forgotPasswordRoute: (context) => ForgotPasswordScreen(),

        // User/Patient Routes
        userHomeRoute: (context) => const UserHomeScreen(),
        userProgressRoute: (context) => const UserProgressHistoryScreen(),
        userNotificationsRoute: (context) => const UserNotificationsScreen(),
        userSettingsRoute: (context) => const UserSettingsScreen(),
        userProfileRoute: (context) => const UserProfileScreen(),
        remindersRoute: (context) => const RemindersListScreen(),
        moodTrackingRoute: (context) => const MoodTrackingScreen(),
        selfAssessmentRoute: (context) => const SelfAssessmentScreen(),
        activitySelectionRoute: (context) => ActivitySelectionScreen(),
        resourcesRoute: (context) => const ResourcesListScreen(),
        doctorsRoute: (context) => const DoctorDirectoryScreen(),

        // Doctor Routes
        doctorHomeRoute: (context) => const DoctorHomeScreen(),
        // --- ADDED ROUTES FOR DOCTOR SECTION ---
        doctorPatientsRoute: (context) => const PatientsScreen(), // Ensure PatientsScreen class exists
        doctorNotesRoute: (context) => const NotesScreen(),       // Ensure NotesScreen class exists
        doctorProfileRoute: (context) => const ProfileScreen(),   // Doctor's Profile Screen
        doctorSettingsRoute: (context) => const SettingsScreen(),  // Doctor's Settings Screen
      },
      debugShowCheckedModeBanner: false,
    );
  }
}