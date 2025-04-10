import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// --- Import Widgets, Models, Constants, and Screens ---
import '../widgets/bottom_nav_bar.dart'; // Ensure this is your actual nav bar
import '../main.dart'; // For route constants if AppCore isn't used

// import '../main_refactored.dart'; // If using AppCore for routes
import '../models/reminder.dart';
import '../providers/theme_provider.dart'; // 2. Import ThemeNotifier
import 'MoodTrackingScreen.dart';

// --- Define Colors (Some fixed, some replaced by theme) ---
// Keep colors that are intentionally fixed by the design regardless of theme
const Color mainAppColor = Color(0xFF5588A4); // Main blue color (used directly or via theme.primary)
const Color fixedLightBlueGrey = Color(0xFFE3EAF1); // FIXED Light background for cards/mood/drawer items
const Color fixedDrawerIconColor = Color(0xFF5588A4); // FIXED Blue color for drawer icons


// These will be primarily replaced by theme, but keep for reference or specific cases
// const Color darkTextColor = Color(0xFF30394F);
// const Color lightTextColor = Color(0xFF6A7185);
// const Color bottomNavColor = Color(0xFF2E5971); // Let theme handle nav bar
// const Color drawerTextColor = Color(0xFF30394F); // Will use theme text color on surface

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
  // --- Reminder Data (Sample - Keep as is) ---
  final List<Reminder> _allReminders = [
    Reminder( id: '1', type: ReminderType.medicine, name: 'Ritalin', amount: 1, time: TimeOfDay(hour: 9, minute: 0), startDate: DateTime.now().subtract(Duration(days: 5)), endDate: DateTime.now().add(Duration(days: 30)), selectedDays: {1, 2, 3, 4, 5}, isCompleted: false),
    Reminder( id: '4', type: ReminderType.activity, name: 'Walk', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {DateTime.now().weekday}, isCompleted: false),
    Reminder( id: '5', type: ReminderType.activity, name: 'Mindfulness', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {DateTime.now().weekday}, isCompleted: false ),
    Reminder( id: '6', type: ReminderType.medicine, name: 'Other Med', amount: 2, time: TimeOfDay(hour: 20, minute: 0), startDate: DateTime.now().subtract(Duration(days: 2)), endDate: DateTime.now().add(Duration(days: 10)), selectedDays: {1, 2, 3, 4, 5, 6, 7}, isCompleted: true),
    Reminder( id: '7', type: ReminderType.activity, name: 'Yoga', time: TimeOfDay(hour: 7, minute: 0), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: { (DateTime.now().weekday % 7) + 1 }, isCompleted: false ),
  ];
  // --- End Reminder Data ---

  List<Reminder> get _todaysReminders {
     final today = DateTime.now();
     final todayDateOnly = DateTime(today.year, today.month, today.day);
     final int currentWeekday = today.weekday;

     return _allReminders.where((reminder) {
        final startDateOnly = DateTime(reminder.startDate.year, reminder.startDate.month, reminder.startDate.day);
        final endDateOnly = DateTime(reminder.endDate.year, reminder.endDate.month, reminder.endDate.day);
        bool dateInRange = !todayDateOnly.isBefore(startDateOnly) && !todayDateOnly.isAfter(endDateOnly);
        bool dayMatches = reminder.selectedDays.contains(currentWeekday);
        return dateInRange && dayMatches;
     }).toList()
     ..sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
  }

  void _toggleReminderCompletionHome(String id) {
    setState(() {
      try {
        final reminder = _allReminders.firstWhere((r) => r.id == id);
        reminder.isCompleted = !reminder.isCompleted;
      } catch (e) { print("Error toggling reminder $id: $e"); }
    });
  }

   Future<bool> _canTrackMoodToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastTrackDateString = prefs.getString('lastMoodTrackDate');
      final String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return lastTrackDateString != todayString;
    } catch (e) { print("Error checking mood track date: $e"); return true; }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Access Theme information
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final todaysRemindersToShow = _todaysReminders;
    const String userName = "Name"; // TODO: Replace with actual user name

    return Scaffold(
      // Let the theme handle the background color
      // backgroundColor: Colors.white, // REMOVED

      appBar: AppBar(
        // Let the theme handle styling (AppBarTheme in main.dart)
        // backgroundColor: Colors.white, // REMOVED
        // foregroundColor: darkTextColor, // REMOVED
        // elevation: 0, // REMOVED (handled by theme)
        // iconTheme: const IconThemeData(color: darkTextColor), // REMOVED
        title: const Text(""), // Keep no title
        actions: [
            Builder(
              builder: (context) => IconButton(
                // Use theme's icon color for the menu icon
                icon: Icon(Icons.menu, color: theme.appBarTheme.iconTheme?.color ?? (isDark ? Colors.white : Colors.black)),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
        ],
        automaticallyImplyLeading: false,
      ),

      endDrawer: _buildUserDrawer(context), // Keep drawer
      bottomNavigationBar: const AppBottomNavBar(), // Use your actual nav bar

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- Greeting ---
              Row(
                children: [
                  Text(
                    'Hello $userName',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // Use theme's secondary text color (often lighter)
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('👋', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),

              // --- Welcome Message ---
              Text(
                'Welcome back',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  // Use theme's primary color
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),

              // --- Mood Tracker Section ---
              Text(
                'How is your mood today',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                   // Use theme's primary color
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),
              _buildMoodTracker(context), // Mood tracker helper (needs internal check)
              const SizedBox(height: 30),

              // --- Today's Reminders Section ---
              Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  // Use theme's primary color
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),

              // --- List of Today's Reminders ---
              if (todaysRemindersToShow.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      "No reminders scheduled for today!",
                      style: GoogleFonts.poppins(
                        // Use theme's secondary text color
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 16
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todaysRemindersToShow.length,
                  itemBuilder: (context, index) {
                    // Build reminder item (needs internal check)
                    return _buildReminderItemHome(context, todaysRemindersToShow[index]);
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  } // End build()

  // --- Builds the User Drawer Menu (Theme Aware) ---
  Widget _buildUserDrawer(BuildContext context) {
     final theme = Theme.of(context);
     final bool isDark = theme.brightness == Brightness.dark;

     return SafeArea(
       child: Drawer(
         // Use theme's standard background for drawers
         backgroundColor: theme.canvasColor,
         child: ListView(
             padding: const EdgeInsets.all(16.0),
             children: <Widget>[
                 Padding(
                   padding: const EdgeInsets.only(bottom: 20.0, top: 10.0, left: 5.0),
                   child: Text(
                     'Menu',
                     style: GoogleFonts.poppins(
                         // Use theme's primary text color on canvas/drawer background
                         color: theme.colorScheme.onSurface,
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),

                // --- Menu Items --- (Pass theme for item building)
                _buildDrawerItem(context, theme, Icons.medical_services_outlined, 'Doctors Directory', MyApp.doctorsRoute), // Assuming AppCore holds routes
                _buildDrawerItem(context, theme, Icons.show_chart_outlined, 'Progress History', MyApp.userProgressRoute),
                _buildDrawerItem(context, theme, Icons.notifications_outlined, 'Notifications', MyApp.userNotificationsRoute),
                _buildDrawerItem(context, theme, Icons.settings_outlined, 'Settings', MyApp.userSettingsRoute),
                _buildDrawerItem(context, theme, Icons.person_outline, 'Profile', MyApp.userProfileRoute),
                _buildDrawerItem(context, theme, Icons.menu_book_outlined, 'Resources', MyApp.resourcesRoute),
                _buildDrawerItem(context, theme, Icons.access_time_outlined, 'Reminders', MyApp.remindersRoute),
                _buildDrawerItem(context, theme, Icons.checklist_outlined, 'Self Assessment', MyApp.selfAssessmentRoute),
             ],
           ),
       ),
     );
  }

  // --- Helper to build individual drawer items (Theme Aware) ---
  Widget _buildDrawerItem(BuildContext context, ThemeData theme, IconData icon, String title, String routeName) {
    final bool isDark = theme.brightness == Brightness.dark;
    // Determine text color based on theme, to show on the FIXED lightBlueGrey background
    final Color itemTextColor = isDark ? Colors.white : theme.colorScheme.onSurface; // White on dark, default on light

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Material(
        color: fixedLightBlueGrey, // FIXED Background color
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            Navigator.pop(context);
            final String? currentRoute = ModalRoute.of(context)?.settings.name;
            final bool isSelected = (currentRoute == routeName || (currentRoute == '/' && routeName == MyApp.userHomeRoute)); // Assuming AppCore
            if (!isSelected) {
               Navigator.pushNamed(context, routeName);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: fixedDrawerIconColor, // FIXED Icon color
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                        color: itemTextColor, // THEME AWARE text color on fixed bg
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // --- Builds the Mood Tracker Widget (Uses fixed background) ---
  Widget _buildMoodTracker(BuildContext context) {
    final theme = Theme.of(context); // Access theme if needed for future elements
    return GestureDetector(
      onTap: () async {
         bool canTrack = await _canTrackMoodToday();
         if (!context.mounted) return;
         if (canTrack) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoodTrackingScreen()),
            );
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               // Use theme for snackbar colors
               backgroundColor: theme.colorScheme.secondary,
               content: Text(
                   'You have already tracked your mood today.',
                   style: GoogleFonts.poppins(color: theme.colorScheme.onSecondary),
                ),
               duration: Duration(seconds: 3),
               behavior: SnackBarBehavior.floating,
             ),
           );
         }
      },
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: fixedLightBlueGrey, // FIXED Background color
            borderRadius: BorderRadius.circular(25),
          ),
          child: Image.asset(
            moodFacesImagePath,
            height: 45,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
               print("Error loading mood faces image: $moodFacesImagePath - $error");
               return Container(
                 height: 45,
                 child: Center(
                   child: Icon(Icons.error_outline, color: theme.colorScheme.error, size: 30),
                 ),
               );
            }
          )
        ),
      ),
    );
  }

  // --- Builds a Reminder Item Card (Theme Aware) ---
   Widget _buildReminderItemHome(BuildContext context, Reminder reminder) {
     final theme = Theme.of(context);
     final bool isDark = theme.brightness == Brightness.dark;
     // Determine text colors for the FIXED lightBlueGrey background
     final Color titleColor = isDark ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface;
     final Color subtitleColor = isDark ? Colors.white.withOpacity(0.7) : theme.textTheme.bodyMedium!.color!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0,
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0) ),
      color: fixedLightBlueGrey, // FIXED Background color
      child: ListTile(
        leading: _getReminderIconHome(context, reminder), // Pass context if needed by icon builder
        title: Text(
          reminder.name,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: titleColor, // THEME AWARE text color
              fontSize: 16
          )
        ),
        subtitle: Text(
          '${reminder.type == ReminderType.medicine ? '${reminder.amount} pill${reminder.amount == 1 ? '' : 's'} ・ ' : ''}${reminder.time.format(context)}',
          style: GoogleFonts.poppins(color: subtitleColor, fontSize: 13), // THEME AWARE text color
        ),
        trailing: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: reminder.isCompleted,
            onChanged: (bool? value) {
               _toggleReminderCompletionHome(reminder.id);
            },
            shape: const CircleBorder(),
            activeColor: theme.colorScheme.primary, // Use theme primary for active checkbox
            checkColor: theme.colorScheme.onPrimary, // Use theme color for checkmark on primary
            // Use theme color for unchecked border or a fixed grey
            side: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 10),
      ),
    );
  }

  // --- Helper to get reminder IMAGE (No theme changes needed here usually) ---
   Widget _getReminderIconHome(BuildContext context, Reminder reminder) {
    // This logic usually remains the same, just returns an Image widget
    String? imagePath;
    switch (reminder.name.toLowerCase()) {
      case 'ritalin': imagePath = iconRitalinPath; break;
      case 'walk': imagePath = iconWalkPath; break;
      case 'mindfulness': imagePath = iconMindfulnessPath; break;
    }
    imagePath ??= reminder.type == ReminderType.medicine ? iconMedicineDefaultPath : iconActivityDefaultPath;

    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $imagePath - $error");
          // Use theme color for fallback icon
          final theme = Theme.of(context);
          return Icon(
            reminder.type == ReminderType.medicine ? Icons.medication_liquid_outlined : Icons.directions_walk,
            color: theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey,
            size: 28,
          );
        },
      ),
    );
  }

} // End of _UserHomeScreenState


// Removed the duplicate MyApp and Reminder/Enum definitions here
// Ensure routes are correctly defined in main.dart or wherever AppCore/MyApp is