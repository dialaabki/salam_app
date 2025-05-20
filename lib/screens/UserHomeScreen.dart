import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Not used directly in this file, but likely needed by ThemeProvider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// --- Firebase Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- End Firebase Imports ---

// --- Import Widgets, Models, Constants, and Screens ---
import '../../widgets/bottom_nav_bar.dart'; // Ensure this is your actual nav bar
import '../../main.dart'; // For route constants

import '../../models/reminder.dart';      // For ReminderType enum
import '../../providers/theme_provider.dart'; // Needed for theme access
import '/screens/MoodTrackingScreen.dart';
import '/screens/Reminders/RemindersListScreen.dart'; // For "View All" button
// import '/screens/Reminders/AddReminderScreen.dart'; // Not used here

// --- Define Colors (Some fixed, some replaced by theme) ---
const Color fixedLightBlueGrey = Color(0xFFE3EAF1);
const Color fixedDrawerIconColor = Color(0xFF5588A4);

// Define Image Asset Paths
const String basePath = "assets/images/";
const String iconRitalinPath = basePath + 'icon_ritalin.png';
const String iconWalkPath = basePath + 'icon_walk.png';
const String iconMindfulnessPath = basePath + 'icon_mindfulness.png';
const String iconMedicineDefaultPath = basePath + 'icon_medicine_default.png';
const String iconActivityDefaultPath = basePath + 'icon_activity_default.png';
const String moodFacesImagePath = basePath + "mood_faces_combined.png";


class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // --- Firestore References ---
  final CollectionReference _remindersCollection = FirebaseFirestore.instance.collection('reminders');
  // Get current user instance - might be null if not logged in
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  // --- End Firestore References ---

  // --- Helper methods for Firestore interaction ---
  String _getDailyCompletionDocId(DateTime date) {
    // Format date as YYYY-MM-DD for consistent document IDs
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _toggleReminderCompletionForDate(String reminderDocId, DateTime date, bool currentIsCompletedForThisDate) async {
    // Ensure user is logged in before modifying Firestore
    if (_currentUser == null) {
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to update reminders.')));
      }
      return;
    }
    final dailyCompletionDocId = _getDailyCompletionDocId(date);
    // Reference to the specific daily completion document within the reminder
    final dailyCompletionRef = _remindersCollection.doc(reminderDocId).collection('dailyCompletions').doc(dailyCompletionDocId);

    try {
      if (currentIsCompletedForThisDate) {
        // If currently completed, delete the document to mark as incomplete
        await dailyCompletionRef.delete();
        print("Home: Unmarked $reminderDocId for $dailyCompletionDocId");
      } else {
        // If currently incomplete, create/set the document to mark as complete
        // Store completion time and user ID for potential future use
        await dailyCompletionRef.set({'completedAt': Timestamp.now(), 'userId': _currentUser!.uid});
        print("Home: Marked $reminderDocId for $dailyCompletionDocId");
      }
      // StreamBuilder handles UI updates automatically, no need for setState usually
    } catch (e) {
      print("Home: Error toggling daily completion: $e");
      if (mounted) { // Show error message if update fails
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }
  // --- End Firestore Helper methods ---


  List<QueryDocumentSnapshot> _getTodaysReminders(List<QueryDocumentSnapshot> allUserDocs) {
     // Return empty list if user is not logged in
     if (_currentUser == null) return [];
     final DateTime today = DateTime.now();
     // print("--- Filtering for UserHomeScreen TODAY: $today (weekday: ${today.weekday}) ---");

     // Filter the documents
     return allUserDocs.where((doc) {
       final data = doc.data() as Map<String, dynamic>?;
       if (data == null) return false; // Skip if data is invalid

      //  final String reminderName = data['name'] ?? 'Unknown Reminder'; // For debugging

       // Basic type validation: ensure necessary fields exist and are of expected types
       if (data['startDate'] is! Timestamp || data['endDate'] is! Timestamp || data['selectedDays'] is! List) {
         // print("[$reminderName - ${doc.id}] Invalid date/day types on home screen.");
         return false;
       }

       // Convert Timestamps to DateTime objects
       final DateTime startDate = (data['startDate'] as Timestamp).toDate();
       final DateTime endDate = (data['endDate'] as Timestamp).toDate();
       // Convert selectedDays (likely List<dynamic>) to List<int>
       final List<int> selectedDaysList = List<int>.from(data['selectedDays']);

       // Skip if no days are selected
       if (selectedDaysList.isEmpty) {
          // print("[$reminderName - ${doc.id}] No selected days.");
          return false;
       }

       // Compare date parts only (year, month, day) to ignore time component
       final selectedDateOnly = DateTime(today.year, today.month, today.day);
       final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
       final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

       // Check if today's date is within the reminder's start and end date range (inclusive)
       bool dateInRange = !selectedDateOnly.isBefore(startDateOnly) && !selectedDateOnly.isAfter(endDateOnly);

       // Check if today's weekday (Monday=1, Sunday=7) is in the list of selected days
       bool dayMatches = selectedDaysList.contains(today.weekday);

      //  print("[$reminderName - ${doc.id}] Date Range: $dateInRange, Day Match: $dayMatches (Today: ${today.weekday}, Selected: $selectedDaysList)");

       // Reminder is valid for today if it's within the date range AND the weekday matches
       return dateInRange && dayMatches;
     }).toList() // Convert the filtered iterable to a List
     ..sort((a, b) { // Sort the list by time of day
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        // Extract hour and minute, providing defaults if null
        final timeA = TimeOfDay(hour: dataA['timeHour'] ?? 0, minute: dataA['timeMinute'] ?? 0);
        final timeB = TimeOfDay(hour: dataB['timeHour'] ?? 0, minute: dataB['timeMinute'] ?? 0);
        // Compare total minutes from midnight for sorting
        final totalMinutesA = timeA.hour * 60 + timeA.minute;
        final totalMinutesB = timeB.hour * 60 + timeB.minute;
        return totalMinutesA.compareTo(totalMinutesB);
      });
  }

   Future<bool> _canTrackMoodToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Get the date string when mood was last tracked
      final String? lastTrackDateString = prefs.getString('lastMoodTrackDate');
      // Get today's date string in the same format
      final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Allow tracking if no date is stored or if stored date is not today
      return lastTrackDateString != todayString;
    } catch (e) {
      print("Error checking mood track date: $e");
      return true; // Default to allowing tracking if there's an error reading preferences
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access theme and user info within build method for context awareness
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // Determine user name: Set to "manar" as requested
    final String userName = "manar";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(""), // Empty title as per original design
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: theme.appBarTheme.elevation ?? 0,
        actions: [
            Builder( // Use Builder to get the correct context for Scaffold.of(context)
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.appBarTheme.iconTheme?.color ?? (isDark ? Colors.white : Colors.black)),
                onPressed: () => Scaffold.of(context).openEndDrawer(), // Open the end drawer
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
        ],
        automaticallyImplyLeading: false, // Don't show the default leading back/menu button
      ),
      endDrawer: _buildUserDrawer(context), // Define the end drawer widget
      bottomNavigationBar: const AppBottomNavBar(), // Your custom bottom navigation bar
      body: SingleChildScrollView( // Allows content to scroll if it exceeds screen height
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding for content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              const SizedBox(height: 10), // Spacing from AppBar
              Row(
                children: [
                  // --- MODIFIED LINE: Use the dynamically determined userName ---
                  Text(
                    'Hello $userName', // Display "Hello" followed by the user's name
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color, // Use theme's text color
                    ),
                  ),
                  // --- End Modification ---
                  const SizedBox(width: 5),
                  const Text('👋', style: TextStyle(fontSize: 18)), // Waving hand emoji
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary, // Use theme's primary color
                ),
              ),
              const SizedBox(height: 30), // Spacing
              Text(
                'How is your mood today',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary, // Use theme's primary color
                ),
              ),
              const SizedBox(height: 15),
              _buildMoodTracker(context), // Mood tracker widget
              const SizedBox(height: 30), // Spacing
              Text(
                'Today', // Section header for reminders
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary, // Use theme's primary color
                ),
              ),
              const SizedBox(height: 15),

              // --- Firestore Powered Today's Reminders Section ---
              _currentUser == null
                  ? Padding( // Show message if user is not logged in
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: Text("Log in to see reminders.", style: TextStyle(color: theme.hintColor))),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      // Listen to changes in the reminders collection for the current user
                      stream: _remindersCollection.where('userId', isEqualTo: _currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        // Show loading indicator while fetching data
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        // Show error message if fetching fails
                        if (snapshot.hasError) {
                          print("Error fetching reminders for home screen: ${snapshot.error}");
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text('Could not load reminders.', style: TextStyle(color: theme.colorScheme.error))),
                          );
                        }
                        // Show message if user has no reminders at all
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text('No active reminders.', style: TextStyle(color: theme.hintColor))),
                          );
                        }

                        // Filter the fetched reminders to get only those scheduled for today
                        final allUserDocs = snapshot.data!.docs;
                        final todaysRemindersDocs = _getTodaysReminders(allUserDocs);

                        // Show message if no reminders are scheduled specifically for today
                        if (todaysRemindersDocs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: Text('No reminders scheduled for today. Enjoy!', style: TextStyle(color: theme.hintColor))),
                          );
                        }

                        // Limit the number of reminders displayed on the home screen (e.g., show max 3)
                        int itemCount = todaysRemindersDocs.length > 3 ? 3 : todaysRemindersDocs.length;

                        // Build the list of reminder items using the filtered & sorted list
                        return Column(
                          children: List.generate(itemCount, (index) {
                             final doc = todaysRemindersDocs[index];
                             final data = doc.data() as Map<String, dynamic>;
                             final String reminderId = doc.id; // Document ID of the reminder

                             // Use another StreamBuilder for each item to listen to its *daily* completion status
                             return StreamBuilder<DocumentSnapshot>(
                               stream: _remindersCollection
                                   .doc(reminderId)
                                   .collection('dailyCompletions') // Subcollection for completion status
                                   .doc(_getDailyCompletionDocId(DateTime.now())) // Document ID for today
                                   .snapshots(),
                               builder: (context, completionSnapshot) {
                                 bool isCompletedForToday = false;
                                 // Check if the completion document for today exists
                                 if (completionSnapshot.connectionState == ConnectionState.active && completionSnapshot.hasData) {
                                   isCompletedForToday = completionSnapshot.data!.exists;
                                 }
                                 // Build the visual representation of the reminder item
                                 return _buildReminderItemHome(
                                     context,
                                     theme, // Pass the current theme
                                     reminderId, // Pass reminder document ID
                                     data, // Pass reminder data (name, time, etc.)
                                     isCompletedForToday, // Pass the current completion status
                                     DateTime.now() // Pass today's date (for toggling function)
                                  );
                               },
                             );
                          }),
                        );
                      },
                    ),
              // --- End Firestore Powered Today's Reminders ---

              const SizedBox(height: 20),
              // Show "View All Reminders" button only if the user is logged in
              if (_currentUser != null)
                Center( // Center the button horizontally
                  child: TextButton.icon(
                    icon: Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
                    label: Text(
                      "View All Reminders",
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)
                    ),
                    onPressed: () {
                      // Navigate to the screen showing all reminders
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersListScreen()));
                    },
                  ),
                ),
              const SizedBox(height: 30), // Add padding at the bottom of the scroll view
            ],
          ),
        ),
      ),
    );
  }

  // Builds the content of the End Drawer (Menu)
  Widget _buildUserDrawer(BuildContext context) {
     final theme = Theme.of(context);
     // final bool isDark = theme.brightness == Brightness.dark; // Can be used for conditional styling

     return SafeArea( // Prevents drawer content from overlapping system UI (status bar, notch)
       child: Drawer(
         backgroundColor: theme.canvasColor, // Use theme's background color for the drawer
         child: ListView(
             padding: const EdgeInsets.all(16.0), // Padding around the entire drawer content
             children: <Widget>[
                 // Drawer Header/Title
                 Padding(
                   padding: const EdgeInsets.only(bottom: 20.0, top: 10.0, left: 5.0),
                   child: Text(
                     'Menu',
                     style: GoogleFonts.poppins(
                         color: theme.colorScheme.onSurface, // Text color appropriate for the background
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 // --- Drawer Navigation Items ---
                 // Use a helper widget to build each item consistently
                _buildDrawerItem(context, theme, Icons.medical_services_outlined, 'Doctors Directory', MyApp.doctorsRoute),
                _buildDrawerItem(context, theme, Icons.show_chart_outlined, 'Progress History', MyApp.userProgressRoute),
                _buildDrawerItem(context, theme, Icons.notifications_outlined, 'Notifications', MyApp.userNotificationsRoute),
                _buildDrawerItem(context, theme, Icons.settings_outlined, 'Settings', MyApp.userSettingsRoute),
                _buildDrawerItem(context, theme, Icons.person_outline, 'Profile', MyApp.userProfileRoute),
                _buildDrawerItem(context, theme, Icons.menu_book_outlined, 'Resources', MyApp.resourcesRoute),
                _buildDrawerItem(context, theme, Icons.access_time_outlined, 'Reminders', MyApp.remindersRoute), // Navigate using the named route
                _buildDrawerItem(context, theme, Icons.checklist_outlined, 'Self Assessment', MyApp.selfAssessmentRoute),
                // Consider adding a Divider and a Logout button here
                // Divider(),
                // _buildDrawerItem(context, theme, Icons.logout, 'Logout', '/logout'), // Example
             ],
           ),
       ),
     );
  }

  // Helper widget to build individual items in the drawer
  Widget _buildDrawerItem(BuildContext context, ThemeData theme, IconData icon, String title, String routeName) {
    // Determine text color suitable for the fixed light blue-grey background
    final Color itemTextColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // Vertical spacing between items
      child: Material( // Use Material for InkWell effect
        color: fixedLightBlueGrey, // Use the FIXED background color for the item
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for the item background
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0), // Match shape for the ripple effect
          onTap: () {
            Navigator.pop(context); // Close the drawer first
            final String? currentRoute = ModalRoute.of(context)?.settings.name;
            // Prevent navigating to the same page the user is already on
            if (currentRoute != routeName) {
               // Use pushNamed if routes are defined in MaterialApp's routes map
               Navigator.pushNamed(context, routeName);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0), // Padding inside the item
            child: Row(
              children: [
                Icon( icon, color: fixedDrawerIconColor, size: 24, ), // Use the FIXED icon color
                const SizedBox(width: 16), // Space between icon and text
                Expanded( // Allow text to wrap if it's too long
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: itemTextColor, // Use calculated text color
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Optionally add a trailing arrow icon:
                // Icon(Icons.chevron_right, color: fixedDrawerIconColor.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the tappable mood tracker widget
  Widget _buildMoodTracker(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector( // Make the whole area tappable
      onTap: () async {
         bool canTrack = await _canTrackMoodToday(); // Check if mood can be tracked today
         if (!context.mounted) return; // Ensure widget is still mounted before proceeding
         if (canTrack) {
            // Navigate to the MoodTrackingScreen if allowed
            Navigator.push( context, MaterialPageRoute(builder: (context) => const MoodTrackingScreen()), );
         } else {
           // Show a message if mood has already been tracked today
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               backgroundColor: theme.colorScheme.secondaryContainer, // Use theme color for SnackBar background
               content: Text(
                 'You have already tracked your mood today.',
                 style: GoogleFonts.poppins(color: theme.colorScheme.onSecondaryContainer), // Use appropriate text color for SnackBar
               ),
               duration: const Duration(seconds: 3), // How long the SnackBar is visible
               behavior: SnackBarBehavior.floating, // Makes the SnackBar float above the BottomNavBar
               margin: const EdgeInsets.all(10), // Add margin when floating
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for floating SnackBar
             ),
           );
         }
      },
      child: FractionallySizedBox( // Control the width relative to the parent
        widthFactor: 0.95, // Make it slightly narrower than the parent padding allows
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Padding inside the container
          decoration: BoxDecoration(
            color: fixedLightBlueGrey, // Use the FIXED background color
            borderRadius: BorderRadius.circular(25), // Rounded corners
          ),
          child: Image.asset(
            moodFacesImagePath, // Path to the combined mood faces image
            height: 45, // Fixed height for the image
            fit: BoxFit.contain, // Ensure the image fits without distortion
            // Add an error builder in case the image asset fails to load
            errorBuilder: (context, error, stackTrace) {
               print("Error loading mood image: $moodFacesImagePath - $error");
               // Show a fallback icon if image loading fails
               return SizedBox(
                 height: 45,
                 child: Center(
                   child: Icon(Icons.sentiment_very_dissatisfied, color: theme.colorScheme.error, size: 30),
                 ),
               );
            }
          )
        ),
      ),
    );
  }

  // --- Builds a single Reminder Item Card for the Home Screen ---
   Widget _buildReminderItemHome(BuildContext context, ThemeData theme, String docId, Map<String, dynamic> data, bool isCompletedForThisDate, DateTime forDate) {
     // Determine colors based on theme brightness, adjusting for the fixed background
     final cardColor = theme.brightness == Brightness.dark
                      ? fixedLightBlueGrey.withOpacity(0.85) // Slightly more opaque fixed color for dark theme
                      : fixedLightBlueGrey; // Fixed color for light theme
     final titleColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface;
     final subtitleColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.7) : theme.textTheme.bodyMedium!.color!;
     final uncheckedBorderColor = theme.dividerColor; // Use theme's divider color for checkbox border

     // Safely extract data from the map, providing default values
     final String name = data['name'] ?? 'Unnamed Reminder';
     final String typeStr = data['type'] ?? 'activity'; // Default to 'activity' if type is missing
     final ReminderType type = typeStr == 'medicine' ? ReminderType.medicine : ReminderType.activity;
     final int? amount = data['amount']; // Amount might be null, especially for activities
     final int hour = data['timeHour'] ?? 0; // Default to midnight if time is missing
     final int minute = data['timeMinute'] ?? 0;
     final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);

     // Construct the subtitle string
     String subtitleText = time.format(context); // Format time according to locale (e.g., 10:30 AM)
     if (type == ReminderType.medicine && amount != null && amount > 0) {
       // Prepend medicine amount if applicable
       subtitleText = '$amount pill${amount == 1 ? '' : 's'} ・ $subtitleText';
     }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0), // Vertical spacing between reminder cards
      elevation: 0, // Keep the card flat (no shadow)
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0) ), // Rounded corners
      color: cardColor, // Apply the determined background color
      child: ListTile(
        leading: _getReminderIconHome(context, theme, name, type), // Get the appropriate icon widget
        title: Text(
          name,
          style: GoogleFonts.poppins( fontWeight: FontWeight.w600, color: titleColor, fontSize: 16 ),
          maxLines: 1, // Prevent title from wrapping to multiple lines
          overflow: TextOverflow.ellipsis, // Show '...' if title is too long
        ),
        subtitle: Text(
          subtitleText,
          style: GoogleFonts.poppins(color: subtitleColor, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Transform.scale( // Make the checkbox slightly larger for easier tapping
          scale: 1.1,
          child: Checkbox(
            value: isCompletedForThisDate, // Reflects the current completion status
            onChanged: (bool? value) {
               // Call the function to update Firestore when the checkbox state changes
               _toggleReminderCompletionForDate(docId, forDate, isCompletedForThisDate);
            },
            shape: const CircleBorder(), // Make the checkbox circular
            activeColor: theme.colorScheme.primary, // Color when checked (use theme's primary color)
            checkColor: theme.colorScheme.onPrimary, // Color of the check mark itself
            // Style the border when the checkbox is unchecked
            side: BorderSide(color: isCompletedForThisDate ? Colors.transparent : uncheckedBorderColor.withOpacity(0.5), width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce extra padding around the checkbox
            visualDensity: VisualDensity.compact, // Make the checkbox itself slightly smaller
          ),
        ),
        // Adjust content padding for better spacing
        contentPadding: const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 10),
      ),
    );
  }

  // --- Helper to get the reminder icon (Image or Fallback Icon) ---
   Widget _getReminderIconHome(BuildContext context, ThemeData theme, String name, ReminderType type) {
    String? imagePath;
    // Try to match specific reminder names (case-insensitive) to custom icons
    switch (name.toLowerCase()) {
      case 'ritalin': imagePath = iconRitalinPath; break;
      case 'walk': imagePath = iconWalkPath; break;
      case 'mindfulness': imagePath = iconMindfulnessPath; break;
      // Add more cases here for other specific reminders with unique icons
    }
    // If no specific match, use the default icon based on reminder type
    imagePath ??= (type == ReminderType.medicine ? iconMedicineDefaultPath : iconActivityDefaultPath);

    return SizedBox( // Constrain the size of the icon container
      width: 40,
      height: 40,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain, // Scales the image down to fit within the bounds
        // Provide an errorBuilder to handle cases where the image asset cannot be loaded
        errorBuilder: (context, error, stackTrace) {
          // print("Error loading home screen icon: $imagePath - $error"); // Log error for debugging
          // Return a fallback Material Design icon based on the reminder type
          return Icon(
            type == ReminderType.medicine ? Icons.medication_liquid_outlined : Icons.directions_walk_rounded,
            color: theme.colorScheme.primary.withOpacity(0.7), // Use a theme color for the fallback icon
            size: 28, // Adjust size as needed
          );
        },
      ),
    );
  }

}

// --- Ensure ReminderType enum is defined ---
// This should ideally be in its own file (e.g., models/reminder.dart) and imported.
// If not defined elsewhere, include it here or in a separate file:
/*
enum ReminderType {
  medicine,
  activity,
}
*/
// --- End ReminderType definition ---