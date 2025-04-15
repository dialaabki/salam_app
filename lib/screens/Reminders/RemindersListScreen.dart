import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart'; // 1. Import Provider

// Import your models and other screens
import '../../models/reminder.dart';
import 'AddReminderScreen.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier

// --- Define Colors (Some may remain for fixed elements) ---
// const Color mainAppColor = Color(0xFF5588A4); // Will use theme.primaryColor
// const Color lightGreyColor = Color(0xFFF0F0F0); // Will use theme surface/variant

// --- Define Image Asset Paths (Keep as is) ---
const String basePath = "assets/images/";
const String iconRitalinPath = basePath + 'icon_ritalin.png';
const String iconSleepPath = basePath + 'icon_sleep.png';
const String iconBreathPath = basePath + 'icon_breath.png';
const String iconWalkPath = basePath + 'icon_walk.png';
const String iconMindfulnessPath = basePath + 'icon_mindfulness.png';
const String iconBreakfreePath = basePath + 'icon_breakfree.png';
const String iconMedicineDefaultPath = basePath + 'icon_medicine_default.png';
const String iconActivityDefaultPath = basePath + 'icon_activity_default.png';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  _RemindersListScreenState createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  // --- Data and State (Keep as is) ---
  final List<Reminder> _allReminders = [
    // Sample Data using names that match the icon logic
    Reminder( id: '1', type: ReminderType.medicine, name: 'Ritalin', amount: 1, time: TimeOfDay(hour: 9, minute: 0), startDate: DateTime.now().subtract(Duration(days: 5)), endDate: DateTime.now().add(Duration(days: 30)), selectedDays: {1, 2, 3, 4, 5}, ),
    Reminder( id: '2', type: ReminderType.activity, name: 'Sleep', time: TimeOfDay(hour: 23, minute: 0), startDate: DateTime.now().subtract(Duration(days: 10)), endDate: DateTime.now().add(Duration(days: 100)), selectedDays: {1, 2, 3, 4, 5, 6, 7}, ),
     Reminder( id: '3', type: ReminderType.activity, name: 'Breath', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {2,4}, ),
    Reminder( id: '4', type: ReminderType.activity, name: 'Walk', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {1,3,5}, ),
     Reminder( id: '5', type: ReminderType.activity, name: 'Mindfulness', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {7}, ),
      Reminder( id: '6', type: ReminderType.activity, name: 'BreakFree', time: TimeOfDay(hour: 17, minute: 30), startDate: DateTime.now().subtract(Duration(days: 1)), endDate: DateTime.now().add(Duration(days: 60)), selectedDays: {6}, ),
      Reminder( id: '7', type: ReminderType.activity, name: 'Yoga', time: TimeOfDay(hour: 8, minute: 0), startDate: DateTime.now().subtract(Duration(days: 2)), endDate: DateTime.now().add(Duration(days: 50)), selectedDays: {2, 4}, ),
  ];
  DateTime _selectedDate = DateTime.now();
  String _generateId() => Random().nextInt(1000000).toString();

  void _addReminder(Reminder newReminder) {
    final reminderWithId = Reminder(
      id: _generateId(), type: newReminder.type, name: newReminder.name,
      time: newReminder.time, startDate: newReminder.startDate, endDate: newReminder.endDate,
      selectedDays: newReminder.selectedDays, amount: newReminder.amount,
      iconAsset: newReminder.iconAsset, isCompleted: false,
    );
    setState(() {
      _allReminders.add(reminderWithId);
      _allReminders.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
    });
  }
  void _removeReminder(String id) { setState(() => _allReminders.removeWhere((r) => r.id == id)); }
  void _toggleReminderCompletion(String id) { setState(() { _allReminders.firstWhere((r) => r.id == id).isCompleted = !_allReminders.firstWhere((r) => r.id == id).isCompleted; }); }

  List<Reminder> get _remindersForSelectedDate {
     return _allReminders.where((reminder) {
      bool dateInRange = (_selectedDate.isAfter(reminder.startDate.subtract(Duration(days: 1))) && _selectedDate.isBefore(reminder.endDate.add(Duration(days: 1)))) ||
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day) == DateTime(reminder.startDate.year, reminder.startDate.month, reminder.startDate.day) ||
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day) == DateTime(reminder.endDate.year, reminder.endDate.month, reminder.endDate.day);
      bool dayMatches = reminder.selectedDays.contains(_selectedDate.weekday);
      return dateInRange && dayMatches;
    }).toList();
  }
  // --- End Data and State ---

  @override
  Widget build(BuildContext context) {
    // --- 3. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    final remindersToShow = _remindersForSelectedDate;
    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.20;

    return Scaffold(
      // 4. Use theme primary color for the background behind the top image
      backgroundColor: theme.colorScheme.primary,
      bottomNavigationBar: const AppBottomNavBar(), // Keep Nav Bar
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<Reminder>( context,
            MaterialPageRoute(builder: (context) => AddReminderScreen(addReminderCallback: _addReminder)),
          );
        },
        // 5. Use theme colors for FAB
        backgroundColor: theme.colorScheme.secondary, // Or primary
        foregroundColor: theme.colorScheme.onSecondary, // Or onPrimary
        child: const Icon(Icons.add),
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
                  // 6. Use theme surface color for the main content background
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Reminders Title ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                      child: Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          // 7. Use theme text color on surface
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // --- Date Selector ---
                    _buildDateSelector(context, theme), // Pass theme

                    // --- "Today", "Tomorrow", etc. Label ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      child: Text(
                        _getDateHeaderText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // 8. Use theme primary color for this label
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    // --- Reminder List ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        itemCount: remindersToShow.length,
                        itemBuilder: (context, index) {
                          final reminder = remindersToShow[index];
                          return _buildReminderItem(context, theme, reminder); // Pass theme
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // End build

  // --- Helper function to get the text for the date header (No theme changes needed) ---
  String _getDateHeaderText() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      if (selectedDay == today) return 'Today';
      if (selectedDay == today.add(const Duration(days: 1))) return 'Tomorrow';
      if (selectedDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
      return DateFormat('EEEE, MMMM d').format(_selectedDate);
  }

  // --- Widget for Date Selection (Theme Aware) ---
  Widget _buildDateSelector(BuildContext context, ThemeData theme) { // Accept theme
    List<DateTime> datesToShow = [];
    for (int i = 0; i <= 4; i++) { datesToShow.add(DateTime.now().add(Duration(days: i))); }

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        height: 75,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: datesToShow.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index){
                 final date = datesToShow[index];
                 bool isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
                 // 9. Define theme-aware colors for chip
                 final chipBackgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
                 final chipSelectedColor = theme.colorScheme.primary;
                 final chipLabelColor = theme.colorScheme.onSurfaceVariant;
                 final chipSelectedLabelColor = theme.colorScheme.onPrimary;

                 return ChoiceChip(
                    label: Column( mainAxisSize: MainAxisSize.min, children: [
                            Text(DateFormat('EEE').format(date), style: TextStyle(fontSize: 12, color: isSelected ? chipSelectedLabelColor : chipLabelColor.withOpacity(0.7))), // Use theme colors
                            const SizedBox(height: 4),
                            Text(DateFormat('d').format(date), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? chipSelectedLabelColor : chipLabelColor)), // Use theme colors
                        ] ),
                    selected: isSelected,
                    onSelected: (bool selected) { if (selected) { setState(() { _selectedDate = date; }); } },
                    selectedColor: chipSelectedColor, // Use theme color
                    backgroundColor: chipBackgroundColor, // Use theme color
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.transparent) ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    showCheckmark: false,
                );
            }
        )
    );
  }

  // --- Widget for a Single Reminder Item (Theme Aware) ---
  Widget _buildReminderItem(BuildContext context, ThemeData theme, Reminder reminder) { // Accept theme
     // 10. Define theme-aware colors for list tile content
     final cardColor = theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceVariant.withOpacity(0.5) // Darker variant for dark mode cards
                      : theme.colorScheme.surfaceVariant.withOpacity(0.8); // Lighter variant for light mode cards
     final titleColor = theme.colorScheme.onSurfaceVariant;
     final subtitleColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
     final uncheckedBorderColor = theme.dividerColor;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeReminder(reminder.id);
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('${reminder.name} removed'), backgroundColor: Colors.redAccent, ), ); // Keep red for remove action
      },
      background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration( color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(15.0), ), // Keep red
          alignment: Alignment.centerRight,
          child: const Row( mainAxisSize: MainAxisSize.min, children: [ Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete_outline, color: Colors.white), ] )
        ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        elevation: 0.5, // Subtle elevation
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0), ),
        // 11. Use theme-aware card color
        color: cardColor,
        child: ListTile(
          leading: _getReminderIcon(context, theme, reminder), // Pass theme to icon builder
          title: Text( reminder.name, style: TextStyle(fontWeight: FontWeight.w500, color: titleColor) ), // Use theme color
          subtitle: Text(
            '${reminder.type == ReminderType.medicine ? '${reminder.amount} pill${reminder.amount == 1 ? '' : 's'} - ' : ''}${reminder.time.format(context)}',
            style: TextStyle(color: subtitleColor), // Use theme color
          ),
          trailing: Checkbox(
            value: reminder.isCompleted,
            onChanged: (bool? value) { _toggleReminderCompletion(reminder.id); },
            shape: const CircleBorder(),
            // 12. Use theme colors for Checkbox
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
            side: BorderSide(color: uncheckedBorderColor, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onTap: () { print("Tapped on ${reminder.name}"); },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  // --- Helper to get reminder IMAGE (Theme Aware Fallback) ---
  Widget _getReminderIcon(BuildContext context, ThemeData theme, Reminder reminder) { // Accept theme
    String? imagePath;
    switch (reminder.name.toLowerCase()) {
      case 'ritalin': imagePath = iconRitalinPath; break;
      case 'sleep': imagePath = iconSleepPath; break;
      case 'breath': imagePath = iconBreathPath; break;
      case 'walk': imagePath = iconWalkPath; break;
      case 'mindfulness': imagePath = iconMindfulnessPath; break;
      case 'breakfree': imagePath = iconBreakfreePath; break;
    }
    imagePath ??= reminder.type == ReminderType.medicine ? iconMedicineDefaultPath : iconActivityDefaultPath;

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.transparent, // Keep transparent bg for image
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 44, height: 44,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading image: $imagePath - $error");
            // 13. Use theme error color for fallback icon
            return Icon(
              reminder.type == ReminderType.medicine ? Icons.medication_outlined : Icons.directions_run, // Changed icons slightly
              color: theme.colorScheme.error,
              size: 24,
            );
          },
        ),
      ),
    );
  } // End of _getReminderIcon

} // End of _RemindersListScreenState