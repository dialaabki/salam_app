import 'package:flutter/material.dart';
// No longer needs provider directly unless used for other state
// import 'package:provider/provider.dart';

// Import the screens to navigate to
import 'AddMedicineScreen.dart';
import 'AddActivityScreen.dart';
// Keep for theme access if needed directly (though Theme.of(context) is usually sufficient)
// import '../../providers/theme_provider.dart';

class AddReminderScreen extends StatelessWidget {
  // Constructor without the callback
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access Theme data
    final theme = Theme.of(context);
    // final bool isDark = theme.brightness == Brightness.dark; // Not directly used here anymore

    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.25;

    // Define button style based on theme for reusability
    final ButtonStyle choiceButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary, // Use theme primary color
      foregroundColor: theme.colorScheme.onPrimary, // Text/icon color on primary
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2), // Optional subtle shadow
    );

    return Scaffold(
      // Use theme primary color for the background behind the top image
      backgroundColor: theme.colorScheme.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Add Reminder',
          style: TextStyle(
            color: Colors.white, // Keep white title on image background
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent, // Keep transparent AppBar
        elevation: 0,
        // Use theme's primary icon theme color OR fallback white for back button
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white), // Ensure back button is white on image
      ),
      body: Column(
        children: [
          // Top Image Area (No theme changes needed)
          Container(
            height: topImageHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg_reminders.png"), // Ensure this image exists
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content Container Area (Theme Aware)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // Use theme surface color for the content background
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Align content towards top
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20), // Add some space at the top
                      // Question Text
                      Text(
                        'What do you need a reminder for?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          // Use theme text color on surface
                          color: theme.colorScheme.onSurface.withOpacity(0.85), // Slightly less muted
                        ),
                      ),
                      const SizedBox(height: 45),

                      // --- Medicine Button ---
                      ElevatedButton(
                        style: choiceButtonStyle, // Apply shared style
                        child: const Text('Medicine'),
                        onPressed: () {
                          // Navigate to AddMedicineScreen (no callback needed)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddMedicineScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // --- Activity Button ---
                      ElevatedButton(
                        style: choiceButtonStyle, // Apply shared style
                        child: const Text('Activity'),
                        onPressed: () {
                          // Navigate to AddActivityScreen (no callback needed)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddActivityScreen(),
                            ),
                          );
                        },
                      ),
                       const Spacer(), // Pushes content up if space allows
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}