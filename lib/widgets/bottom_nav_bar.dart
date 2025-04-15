import 'package:flutter/material.dart';
import 'dart:async';

// *** IMPORT YOUR main.dart FILE ***
// Adjust the path '..' if main.dart is in a different relative location
import '../main.dart'; // Assuming main.dart is in the 'lib' folder and this widget is in 'lib/widgets'

class AppBottomNavBar extends StatelessWidget {
  final Timer? navigationTimer;

  const AppBottomNavBar({Key? key, this.navigationTimer}) : super(key: key);

  void _navigate(BuildContext context, String routeName) {
    navigationTimer?.cancel();
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName != routeName) {
      Navigator.pushNamed(context, routeName);
    }
  }

  void _navigateHome(BuildContext context) {
    navigationTimer?.cancel();
    // Navigate to the route defined as home ('/') using its constant
    // Pop until first is usually okay if '/' is always the base.
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName != MyApp.userHomeRoute) {
       Navigator.popUntil(context, (route) => route.settings.name == MyApp.userHomeRoute || route.isFirst);
       // If popUntil doesn't reliably get you home (e.g., if you used pushReplacement), use:
       // Navigator.pushNamedAndRemoveUntil(context, MyApp.userHomeRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    // --- Use Constants Imported from MyApp ---
    // No need to redefine constants here

    // Define colors
    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(0xFF5E94FF);
    const Color barBackgroundColor = Color(0xFF276181);

    return BottomAppBar(
      color: barBackgroundColor,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: 'Home',
            // Use the constant from main.dart for comparison
            icon: Icon(Icons.home, color: currentRouteName == MyApp.userHomeRoute ? activeColor : inactiveColor),
            onPressed: () => _navigateHome(context),
          ),
          IconButton(
            tooltip: 'Reminders',
            // Use the constant from main.dart for comparison and navigation
            icon: Icon(Icons.access_time, color: currentRouteName == MyApp.remindersRoute ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, MyApp.remindersRoute),
          ),
          IconButton(
            tooltip: 'Activity',
            // Use the constant from main.dart for comparison and navigation
            icon: Icon(Icons.checklist, color: currentRouteName == MyApp.activitySelectionRoute ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, MyApp.activitySelectionRoute),
          ),
          IconButton(
            tooltip: 'Resources',
            // Use the constant from main.dart for comparison and navigation
            icon: Icon(Icons.menu_book, color: currentRouteName == MyApp.resourcesRoute ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, MyApp.resourcesRoute),
          ),
          IconButton(
            tooltip: 'Profile',
            // Use the constant from main.dart for comparison and navigation
            icon: Icon(Icons.person, color: currentRouteName == MyApp.userProfileRoute ? activeColor : inactiveColor),
            onPressed: () => _navigate(context, MyApp.userProfileRoute),
          ),
        ],
      ),
    );
  }
}
