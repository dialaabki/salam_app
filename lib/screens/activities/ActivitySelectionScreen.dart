// File: lib/screens/activities/activity_selection_screen.dart

import 'package:flutter/material.dart';
// Removed dart:async as it's likely not needed directly in this screen anymore

// --- Ensure this import path is correct for YOUR project ---
// It should point to where you saved the AppBottomNavBar class
import '../../widgets/bottom_nav_bar.dart';

// --- Ensure these import paths match your ACTUAL filenames ---
import 'SleepActivityScreen.dart';
import 'BreathingIntroScreen.dart';
import 'MindfulnessActivityScreen.dart';
import 'WalkingActivityScreen.dart';
import 'BreakFreeScreen.dart';
// --- End Imports ---

class ActivitySelectionScreen extends StatelessWidget {
  static const routeName = '/activitySelection'; // Good practice route name

  final List<Map<String, dynamic>> activities = [
    {
      'label': 'Sleep',
      'icon': 'assets/images/sleep_icon.png',
      'target': SleepActivityScreen(),
    },
    {
      'label': 'Breath',
      'icon': 'assets/images/breath_icon.png',
      'target': BreathingIntroScreen(),
    },
    {
      'label': 'Mindful',
      'icon': 'assets/images/mindful_icon.png',
      'target': MindfulnessActivityScreen(),
    },
    {
      'label': 'Walk',
      'icon': 'assets/images/walk_icon.png',
      'target': WalkingActivityScreen(),
    },
    {
      'label': 'BreakFree',
      'icon': 'assets/images/breakfree_icon.png',
      'target': BreakFreeScreen(),
    },
  ];

  const ActivitySelectionScreen({super.key});

  Widget _buildActivityItem(
    BuildContext context,
    Map<String, dynamic> activityData,
  ) {
    final Color buttonBgColor = Color(0xFF6B91A8);
    final Color textColor = Color(0xFF1E4B5F);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => activityData['target'] as Widget,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: buttonBgColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.white.withOpacity(0.5),
                  ),
            ),
            SizedBox(height: 10),
            Text(
              activityData['label'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
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
    final Color primaryTextColor = Color(0xFF1E4B5F);
    final Color secondaryTextColor = Color(0xFF3E8A9A);
    final Color mainContentBgColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/activity_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: mainContentBgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(35.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30.0,
                        horizontal: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activities',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose your activity',
                            style: TextStyle(
                              fontSize: 18,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 30),
                          Wrap(
                            spacing: 20.0,
                            runSpacing: 20.0,
                            alignment: WrapAlignment.start,
                            children:
                                activities.map((activityData) {
                                  // Calculate width dynamically
                                  double horizontalPadding =
                                      40.0; // Approx total horizontal padding (20*2)
                                  double spacingBetweenItems = 20.0;
                                  int itemsPerRow =
                                      2; // Aim for 2 items per row
                                  double itemWidth =
                                      (MediaQuery.of(context).size.width -
                                          horizontalPadding -
                                          spacingBetweenItems *
                                              (itemsPerRow - 1)) /
                                      itemsPerRow;
                                  // Add a minimum width constraint if needed
                                  itemWidth = itemWidth < 100 ? 100 : itemWidth;

                                  return SizedBox(
                                    width: itemWidth,
                                    child: _buildActivityItem(
                                      context,
                                      activityData,
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(height: 20),
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
      // --- THIS LINE IS CORRECTED ---
      // Use the AppBottomNavBar class constructor
      bottomNavigationBar: const AppBottomNavBar(),
      // --- END CORRECTION ---
    );
  }
}
