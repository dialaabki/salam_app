// File: lib/screens/activities/activity_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider

// --- Ensure this import path is correct for YOUR project ---
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier

// --- Ensure these import paths match your ACTUAL filenames ---
import 'SleepActivityScreen.dart';
import 'BreathingIntroScreen.dart';
import 'MindfulnessActivityScreen.dart';
import 'WalkingActivityScreen.dart';
import 'BreakFreeScreen.dart';
// --- End Imports ---


class ActivitySelectionScreen extends StatelessWidget {
  static const routeName = '/activitySelection';

  // Define activity data (Keep as is)
  final List<Map<String, dynamic>> activities = [
    {'label': 'Sleep','icon': 'assets/images/sleep_icon.png','target': SleepActivityScreen(),},
    {'label': 'Breath','icon': 'assets/images/breath_icon.png','target': BreathingIntroScreen(),},
    {'label': 'Mindful','icon': 'assets/images/mindful_icon.png','target': MindfulnessActivityScreen(),},
    {'label': 'Walk','icon': 'assets/images/walk_icon.png','target': WalkingActivityScreen(), },
    {'label': 'BreakFree','icon': 'assets/images/breakfree_icon.png','target': BreakFreeScreen(),},
  ];

  // --- Helper to build Activity Item (Theme Aware) ---
  Widget _buildActivityItem(BuildContext context, ThemeData theme, Map<String, dynamic> activityData) { // Accept theme
    final bool isDark = theme.brightness == Brightness.dark;

    // 3. Define button colors based on theme
    final Color buttonBgColor = theme.colorScheme.secondaryContainer; // Example: A secondary container color
    final Color textColor = theme.colorScheme.onSecondaryContainer; // Text color that contrasts with the above
    final Color iconErrorColor = theme.colorScheme.onErrorContainer; // Or just onError

    return GestureDetector(
      onTap: () {
        // Ensure target screens are theme aware when navigating
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => activityData['target'] as Widget),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: buttonBgColor, // Use theme color
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [ // Keep subtle shadow or adjust based on theme elevation
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.15), // Slightly darker shadow in dark mode maybe
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              activityData['icon'] as String,
              height: 60,
              // Consider using theme color for error icon if image fails
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.error_outline, size: 60, color: iconErrorColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 10),
            Text(
              activityData['label'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor, // Use theme color
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // --- 4. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    // 5. Define text/background colors using theme
    final Color primaryTextColor = theme.colorScheme.onSurface; // Primary text on the main content area
    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant; // Secondary text on main content area
    final Color mainContentBgColor = theme.colorScheme.surface; // Background of the bottom sheet part

    return Scaffold(
      // 6. Set Scaffold background (maybe primary or surface, depending on desired look behind image)
      backgroundColor: theme.colorScheme.primaryContainer, // Example: Match top image area tone slightly

      body: Stack(
        children: [
          // Background Image (Keep as is, maybe adjust blendMode if needed for dark theme)
          Positioned.fill(
            child: Image.asset(
              'assets/images/activity_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              // Optional: Add blend mode for dark theme?
              // colorBlendMode: isDark ? BlendMode.darken : BlendMode.srcOver,
              // color: isDark ? Colors.black.withOpacity(0.2) : null,
            ),
          ),
          SafeArea(
            bottom: false, // Keep nav bar space clear
            child: Column(
              children: [
                // Spacer (Keep percentage or adjust based on visual need)
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: mainContentBgColor, // Use theme color
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(35.0),
                      ),
                      // Optional: Add a subtle top border in dark mode?
                      // border: isDark ? Border(top: BorderSide(color: theme.dividerColor, width: 0.5)) : null,
                    ),
                    child: SingleChildScrollView(
                       padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             'Activities',
                             style: TextStyle(
                               fontSize: 28,
                               fontWeight: FontWeight.bold,
                               color: primaryTextColor, // Use theme color
                             ),
                           ),
                           SizedBox(height: 8),
                           Text(
                             'Choose your activity',
                             style: TextStyle(
                               fontSize: 18,
                               color: secondaryTextColor, // Use theme color
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                           SizedBox(height: 30),
                           Wrap(
                             spacing: 20.0,
                             runSpacing: 20.0,
                             alignment: WrapAlignment.start,
                             children: activities.map((activityData) {
                               // Dynamic width calculation (Keep as is)
                               double horizontalPadding = 40.0;
                               double spacingBetweenItems = 20.0;
                               int itemsPerRow = 2;
                               double itemWidth = (MediaQuery.of(context).size.width - horizontalPadding - spacingBetweenItems * (itemsPerRow - 1)) / itemsPerRow;
                               itemWidth = itemWidth < 100 ? 100 : itemWidth;

                               return SizedBox(
                                 width: itemWidth,
                                 // Pass theme to the item builder
                                 child: _buildActivityItem(context, theme, activityData),
                               );
                             }).toList(),
                           ),
                           SizedBox(height: 20), // Bottom padding inside scroll view
                         ],
                       ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Use your actual AppBottomNavBar (Ensure it's theme aware)
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}