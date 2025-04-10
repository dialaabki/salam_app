import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../../models/reminder.dart';
import 'AddMedicineScreen.dart'; // Make sure this screen is also theme-aware
import 'AddActivityScreen.dart'; // Make sure this screen is also theme-aware
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier

// --- Define Colors (Replaced by theme where applicable) ---
// const Color mainAppColor = Color(0xFF5588A4); // Will use theme.primaryColor

class AddReminderScreen extends StatelessWidget {
  final Function(Reminder) addReminderCallback;

  const AddReminderScreen({Key? key, required this.addReminderCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 3. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.25;

    return Scaffold(
      // 4. Use theme primary color for the background behind the top image
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
        // 5. Use theme's primary icon theme color OR fallback white for back button
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white), // Ensure back button is white on image
      ),
      body: Column(
        children: [
          // --- 1. Top Image Area (No theme changes needed) ---
          Container(
            height: topImageHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg_reminders.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // --- 2. Content Container Area (Theme Aware) ---
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // 6. Use theme surface color for the content background
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Question Text ---
                      Text(
                        'What do you need a reminder for?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          // 7. Use theme text color on surface
                          color: theme.colorScheme.onSurface.withOpacity(0.8), // Slightly muted
                        ),
                      ),
                      const SizedBox(height: 45),

                      // --- Medicine Button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // 8. Use theme colors for button
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          elevation: 3,
                        ),
                        child: const Text('Medicine'),
                        onPressed: () {
                          // Ensure AddMedicineScreen is theme aware
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMedicineScreen(addReminderCallback: addReminderCallback),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // --- Activity Button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // 9. Use theme colors for button
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          elevation: 3,
                        ),
                        child: const Text('Activity'),
                        onPressed: () {
                          // Ensure AddActivityScreen is theme aware
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivityScreen(addReminderCallback: addReminderCallback),
                            ),
                          );
                        },
                      ),
                       const Spacer(),
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