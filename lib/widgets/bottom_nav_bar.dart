// File: lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Keep only if timer is actually used/passed

// Define a reusable StatelessWidget for the Bottom Navigation Bar
class AppBottomNavBar extends StatelessWidget {
  // If you don't actually need to pass a timer from the screens, remove this.
  final Timer? navigationTimer;

  // *** Ensure this constructor is marked as const ***
  const AppBottomNavBar({super.key, this.navigationTimer});

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
    // Pop until the first route (usually the home screen defined as '/')
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Get current route name inside build method
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    // Define target route names explicitly
    const String activitySelectionRoute =
        '/activitySelection'; // Or '/activity' if that's your route name
    const String remindersRoute = '/reminders';
    const String resourcesRoute =
        '/resources'; // <-- Define resources route name
    const String profileRoute = '/profile';

    // Determine if on the specific activity selection screen
    // final bool isExactlyActivitySelectionScreen = currentRouteName == activitySelectionRoute;

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
            icon: Icon(
              Icons.home,
              color: currentRouteName == '/' ? activeColor : inactiveColor,
            ), // Highlight if '/'
            onPressed: () => _navigateHome(context),
          ),
          IconButton(
            tooltip: 'Reminders',
            icon: Icon(
              Icons.access_time,
              color:
                  currentRouteName == remindersRoute
                      ? activeColor
                      : inactiveColor,
            ),
            onPressed: () => _navigate(context, remindersRoute),
          ),
          IconButton(
            tooltip: 'Activity',
            icon: Icon(
              Icons.checklist,
              color:
                  currentRouteName == activitySelectionRoute
                      ? activeColor
                      : inactiveColor,
            ),
            onPressed: () => _navigate(context, activitySelectionRoute),
          ),
          // --- UPDATED ICON FOR RESOURCES ---
          IconButton(
            tooltip: 'Resources', // <-- Changed tooltip
            icon: Icon(
              Icons.menu_book,
              color:
                  currentRouteName == resourcesRoute
                      ? activeColor
                      : inactiveColor,
            ), // <-- Check against resourcesRoute
            onPressed:
                () => _navigate(
                  context,
                  resourcesRoute,
                ), // <-- Navigate to resourcesRoute
          ),
          // --- END OF UPDATE ---
          IconButton(
            tooltip: 'Profile',
            icon: Icon(
              Icons.person,
              color:
                  currentRouteName == profileRoute
                      ? activeColor
                      : inactiveColor,
            ),
            onPressed: () => _navigate(context, profileRoute),
          ),
        ],
      ),
    );
  }
}
