// File: lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Keep only if timer is actually used/passed
import 'package:salam_app/screens/activities/ActivitySelectionScreen.dart';

// Define a reusable StatelessWidget for the Bottom Navigation Bar
class AppBottomNavBar extends StatelessWidget {
  // If you don't actually need to pass a timer from the screens, remove this.
  final Timer? navigationTimer;

  // *** Ensure this constructor is marked as const ***
  const AppBottomNavBar({Key? key, this.navigationTimer}) : super(key: key);

  // Helper function to handle navigation logic
  void _navigate(BuildContext context, String routeName) {
    // Only try to cancel if a timer was actually passed
    navigationTimer?.cancel();

    // Get current route name *inside* the method when needed
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    // Only push if not already on the target route
    if (currentRouteName != routeName) {
      // Consider navigation strategy: pushNamed, pushReplacementNamed, pushNamedAndRemoveUntil
      Navigator.pushNamed(context, routeName);
    }
  }

  // Helper function to navigate home
  void _navigateHome(BuildContext context) {
    navigationTimer?.cancel();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Get current route name inside build method
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    // Define target route for activity selection
    const String activitySelectionRoute = '/activitySelection';

    // Determine if on the specific activity selection screen
    final bool isExactlyActivitySelectionScreen = currentRouteName == activitySelectionRoute;

    // Define colors
    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(0xFF5E94FF);
    const Color barBackgroundColor = Color(0xFF276181);

    return BottomAppBar(
      color: barBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Home',
            icon: Icon(Icons.home, color: inactiveColor), // Assuming home isn't highlighted via route name
            onPressed: () => _navigateHome(context),
          ),
          IconButton(
            tooltip: 'Reminders',
            // Use direct comparison for highlighting
            icon: Icon(Icons.access_time, color: currentRouteName == '/reminders' ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, '/reminders'),
          ),
          IconButton(
  tooltip: 'Activity',
  icon: Icon(
    Icons.checklist,
    color: currentRouteName == activitySelectionRoute ? activeColor : inactiveColor,
  ),
  onPressed: () => _navigate(context, activitySelectionRoute), // Correct route name
),

          IconButton(
            tooltip: 'Doctors',
            icon: Icon(Icons.menu_book, color: currentRouteName == '/doctors' ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, '/doctors'),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: Icon(Icons.person, color: currentRouteName == '/profile' ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, '/profile'),
          ),
        ],
      ),
    );
  }
}