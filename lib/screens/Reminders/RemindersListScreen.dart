import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Used for ThemeNotifier if not directly accessing theme
// --- Firebase Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- End Firebase Imports ---

// Import models and other screens
import '../../models/reminder.dart'; // Ensure ReminderType enum is defined here
import 'AddReminderScreen.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/theme_provider.dart'; // For theme access

// --- Image Asset Paths ---
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
  DateTime _selectedDate = DateTime.now();

  // --- Firestore References ---
  final CollectionReference _remindersCollection = FirebaseFirestore.instance.collection('reminders');
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  // --- End Firestore References ---


  // --- Firestore Helper Methods ---
  String _getDailyCompletionDocId(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _toggleReminderCompletionForDate(String reminderDocId, DateTime date, bool currentIsCompletedForThisDate) async {
    if (_currentUser == null) {
      print("Cannot toggle completion: User not logged in.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to update reminders.'), backgroundColor: Colors.orange));
      }
      return;
    }

    final dailyCompletionDocId = _getDailyCompletionDocId(date);
    final dailyCompletionRef = _remindersCollection.doc(reminderDocId).collection('dailyCompletions').doc(dailyCompletionDocId);

    try {
      if (currentIsCompletedForThisDate) {
        await dailyCompletionRef.delete();
        print("Unmarked reminder $reminderDocId as completed for $dailyCompletionDocId");
      } else {
        await dailyCompletionRef.set({
          'completedAt': Timestamp.now(),
          'userId': _currentUser!.uid, // Good to have for potential auditing
        });
        print("Marked reminder $reminderDocId as completed for $dailyCompletionDocId");
      }
    } catch (e) {
      print("Error toggling daily completion status ($reminderDocId for $dailyCompletionDocId): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _removeReminderFirestore(String docId, String reminderName) async {
    if (_currentUser == null) {
        print("Cannot remove reminder: User not logged in.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to manage reminders.'), backgroundColor: Colors.orange));
        }
        return;
    }
    try {
      await _remindersCollection.doc(docId).delete();
      // TODO: Implement robust deletion of 'dailyCompletions' subcollection for this reminder.
      // This typically requires a Cloud Function for atomicity and completeness,
      // or iterating through and deleting documents client-side (less efficient and can be interrupted).
      // For now, subcollection docs might be orphaned if the main reminder is deleted.
      print("Reminder $docId ($reminderName) deleted. Associated dailyCompletions may be orphaned.");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$reminderName removed'), backgroundColor: Colors.orangeAccent)
        );
      }
    } catch (e) {
      print("Error removing reminder ($docId): $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove reminder: ${e.toString()}'), backgroundColor: Colors.red)
        );
      }
    }
  }
  // --- End Firestore Helper Methods ---

  // --- Filter Logic ---
  List<QueryDocumentSnapshot> _filterRemindersForSelectedDate(List<QueryDocumentSnapshot> allDocs) {
    if (_currentUser == null) return [];

    // print("--- Filtering for _selectedDate: $_selectedDate (weekday: ${_selectedDate.weekday}) ---"); // Can be verbose

    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        // print("Doc ID ${doc.id}: Data is null. Skipping.");
        return false;
      }

      final String reminderName = data['name'] ?? 'Unknown Reminder';


      if (data['startDate'] is! Timestamp || data['endDate'] is! Timestamp || data['selectedDays'] is! List) {
        // print("[$reminderName - ${doc.id}] Invalid date/day types. startDate: ${data['startDate']?.runtimeType}, endDate: ${data['endDate']?.runtimeType}, selectedDays: ${data['selectedDays']?.runtimeType}");
        return false;
      }

      final Timestamp startTimestamp = data['startDate'];
      final Timestamp endTimestamp = data['endDate'];
      final DateTime startDate = startTimestamp.toDate();
      final DateTime endDate = endTimestamp.toDate();
      final List<dynamic> daysDynamic = data['selectedDays'];
      final List<int> selectedDaysList = daysDynamic.map((day) => day is int ? day : int.tryParse(day.toString()) ?? -1).where((day) => day != -1).toList();

      if (selectedDaysList.isEmpty) {
          // print("[$reminderName - ${doc.id}] Empty selectedDaysList after conversion.");
          return false;
      }

      final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

      bool dateInRange = !selectedDateOnly.isBefore(startDateOnly) && !selectedDateOnly.isAfter(endDateOnly);
      bool dayMatches = selectedDaysList.contains(_selectedDate.weekday);

      // Detailed print for specific debugging if needed:
      // if (reminderName.toLowerCase().contains("specific_test_name")) {
      //    print("[$reminderName - ${doc.id}] dateInRange: $dateInRange, dayMatches: $dayMatches (UI weekday: ${_selectedDate.weekday}, DB days: $selectedDaysList)");
      // }

      return dateInRange && dayMatches;
    }).toList()
    ..sort((a, b) { // Sort the filtered list by time
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final timeA = TimeOfDay(hour: dataA['timeHour'] ?? 0, minute: dataA['timeMinute'] ?? 0);
        final timeB = TimeOfDay(hour: dataB['timeHour'] ?? 0, minute: dataB['timeMinute'] ?? 0);
        final totalMinutesA = timeA.hour * 60 + timeA.minute;
        final totalMinutesB = timeB.hour * 60 + timeB.minute;
        return totalMinutesA.compareTo(totalMinutesB);
     });
  }
  // --- End Filter Logic ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.20;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      bottomNavigationBar: const AppBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push( context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Top Image Area
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
          // Content Container Area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                      child: Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildDateSelector(context, theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      child: Text(
                        _getDateHeaderText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    // --- Reminder List (Using Nested StreamBuilders) ---
                    Expanded(
                      child: _currentUser == null
                        ? Center(child: Text("Please log in to view reminders.", style: TextStyle(color: theme.hintColor)))
                        : StreamBuilder<QuerySnapshot>(
                            stream: _remindersCollection.where('userId', isEqualTo: _currentUser!.uid).snapshots(),
                            builder: (context, reminderSnapshot) {
                              if (reminderSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (reminderSnapshot.hasError) {
                                print("Firestore Stream Error (Outer): ${reminderSnapshot.error}");
                                return Center(child: Text('Error loading reminders.', style: TextStyle(color: theme.colorScheme.error)));
                              }
                              if (!reminderSnapshot.hasData || reminderSnapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No reminders added yet.', style: TextStyle(color: theme.hintColor)));
                              }

                              final allUserReminderDocs = reminderSnapshot.data!.docs;
                              final remindersToShowDocs = _filterRemindersForSelectedDate(allUserReminderDocs);

                              if (remindersToShowDocs.isEmpty) {
                                 return Center(child: Text('No reminders for ${DateFormat('MMM d').format(_selectedDate)}.', style: TextStyle(color: theme.hintColor)));
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                itemCount: remindersToShowDocs.length,
                                itemBuilder: (context, index) {
                                  final reminderDoc = remindersToShowDocs[index];
                                  final reminderData = reminderDoc.data() as Map<String, dynamic>;
                                  final String reminderId = reminderDoc.id;

                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: _remindersCollection
                                        .doc(reminderId)
                                        .collection('dailyCompletions')
                                        .doc(_getDailyCompletionDocId(_selectedDate))
                                        .snapshots(),
                                    builder: (context, completionSnapshot) {
                                      bool isCompletedForThisDate = false;
                                      // Only consider 'exists' if the stream is active and has data
                                      if (completionSnapshot.connectionState == ConnectionState.active && completionSnapshot.hasData) {
                                        isCompletedForThisDate = completionSnapshot.data!.exists;
                                      }
                                      // While waiting for completion status, assume not completed or show placeholder
                                      // else if (completionSnapshot.connectionState == ConnectionState.waiting) {
                                      //    return ListTile(title: Text(reminderData['name'] ?? 'Loading status...'));
                                      // }
                                      // You might also want to handle completionSnapshot.hasError

                                      return _buildReminderItem(
                                        context,
                                        theme,
                                        reminderId,
                                        reminderData,
                                        isCompletedForThisDate,
                                        _selectedDate // Pass the specific date this item instance is for
                                      );
                                    },
                                  );
                                },
                              );
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
  }

  String _getDateHeaderText() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      if (selectedDay == today) return 'Today';
      if (selectedDay == today.add(const Duration(days: 1))) return 'Tomorrow';
      if (selectedDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
      return DateFormat('EEEE, MMMM d').format(_selectedDate);
  }

  Widget _buildDateSelector(BuildContext context, ThemeData theme) {
    List<DateTime> datesToShow = [];
    final baseDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    for (int i = -3; i <= 4; i++) { datesToShow.add(baseDate.add(Duration(days: i))); }
    int initialIndex = datesToShow.indexWhere((date) => date == baseDate);
    if (initialIndex == -1) initialIndex = 3;
    ScrollController dateScrollController = ScrollController( initialScrollOffset: initialIndex * (65.0 + 8.0) - (MediaQuery.of(context).size.width / 2) + 32.5 );

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        height: 75,
        child: ListView.separated(
            controller: dateScrollController, scrollDirection: Axis.horizontal,
            itemCount: datesToShow.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index){
                 final date = datesToShow[index];
                 bool isSelected = date == baseDate;
                 final chipBackgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
                 final chipSelectedColor = theme.colorScheme.primary;
                 final chipLabelColor = theme.colorScheme.onSurfaceVariant;
                 final chipSelectedLabelColor = theme.colorScheme.onPrimary;

                 return ChoiceChip(
                    label: Column( mainAxisSize: MainAxisSize.min, children: [
                            Text(DateFormat('EEE').format(date), style: TextStyle(fontSize: 12, color: isSelected ? chipSelectedLabelColor : chipLabelColor.withOpacity(0.7))),
                            const SizedBox(height: 4),
                            Text(DateFormat('d').format(date), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? chipSelectedLabelColor : chipLabelColor)),
                        ] ),
                    selected: isSelected,
                    onSelected: (bool selected) { if (selected) { setState(() { _selectedDate = date; }); } },
                    selectedColor: chipSelectedColor,
                    backgroundColor: chipBackgroundColor,
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.transparent) ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    showCheckmark: false,
                );
            }
        )
    );
  }

  Widget _buildReminderItem(BuildContext context, ThemeData theme, String docId, Map<String, dynamic> data, bool isCompletedForThisDate, DateTime forDate) {
     final cardColor = theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.8);
     final titleColor = theme.colorScheme.onSurfaceVariant;
     final subtitleColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
     final uncheckedBorderColor = theme.dividerColor;

     final String name = data['name'] ?? 'Unnamed Reminder';
     final String typeStr = data['type'] ?? 'activity';
     final ReminderType type = typeStr == 'medicine' ? ReminderType.medicine : ReminderType.activity;
     final int? amount = data['amount'];
     final int hour = data['timeHour'] ?? 0;
     final int minute = data['timeMinute'] ?? 0;
     final TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
     String subtitleText = time.format(context);
     if (type == ReminderType.medicine && amount != null) {
       subtitleText = '$amount pill${amount == 1 ? '' : 's'} - $subtitleText';
     }

    return Dismissible(
      key: ValueKey(docId + forDate.toIso8601String()), // Make key unique per date instance
      direction: DismissDirection.endToStart,
      onDismissed: (direction) { _removeReminderFirestore(docId, name); },
      background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration( color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(15.0), ),
          alignment: Alignment.centerRight,
          child: const Row( mainAxisSize: MainAxisSize.min, children: [ Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete_outline, color: Colors.white), ] )
        ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0), ),
        color: cardColor,
        child: ListTile(
          leading: _getReminderIconFromData(context, theme, name, type),
          title: Text( name, style: TextStyle(fontWeight: FontWeight.w500, color: titleColor) ),
          subtitle: Text( subtitleText, style: TextStyle(color: subtitleColor), ),
          trailing: Checkbox(
            value: isCompletedForThisDate,
            onChanged: (bool? value) {
              _toggleReminderCompletionForDate(docId, forDate, isCompletedForThisDate);
            },
            shape: const CircleBorder(),
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
            side: BorderSide(color: uncheckedBorderColor, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _getReminderIconFromData(BuildContext context, ThemeData theme, String name, ReminderType type) {
    String? imagePath;
    switch (name.toLowerCase()) {
      case 'ritalin': imagePath = iconRitalinPath; break;
      case 'sleep': imagePath = iconSleepPath; break;
      case 'breath': imagePath = iconBreathPath; break;
      case 'walk': imagePath = iconWalkPath; break;
      case 'mindfulness': imagePath = iconMindfulnessPath; break;
      case 'breakfree': imagePath = iconBreakfreePath; break;
    }
    imagePath ??= type == ReminderType.medicine ? iconMedicineDefaultPath : iconActivityDefaultPath;

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover, width: 44, height: 44,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading image: $imagePath - $error");
            return Icon(
              type == ReminderType.medicine ? Icons.medication_outlined : Icons.directions_run,
              color: theme.colorScheme.error, size: 24,
            );
          },
        ),
      ),
    );
  }

}

// Ensure ReminderType enum is defined, e.g., in models/reminder.dart
