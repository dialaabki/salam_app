import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter (though not strictly needed if removing blur/gradient)

// --- Colors (Keep as defined previously) ---
const Color kPrimaryTeal = Color(0xFF5C9DAD); // Main teal color from image
const Color kHeaderBlueTint = Color(
  0xFF8EB5C0,
); // Adjusted approximate background tint of the header image
const Color kDarkTeal = Color(0xFF3E6A7A); // Bottom nav bar color
const Color kGreyBackground = Color(0xFFE0E0E0);
const Color kLightBlueGrey = Color(0xFFE3EDF3); // Reminder item background
const Color kRedRemove = Color(0xFFFF5C5C);
const Color kWhite = Colors.white;
const Color kGreyText = Colors.grey;
const Color kDarkGreyText = Color(0xFF555555);
const Color kTitleColor = Color(
  0xFF4A7C89,
); // Darker teal for title text on white background

// --- Reminder Model (Keep as is) ---
class Reminder {
  final String id;
  final String iconPath;
  final String title;
  final String? details;
  final String time;
  bool isCompleted;
  final bool showRemoveAction;

  Reminder({
    required this.id,
    required this.iconPath,
    required this.title,
    this.details,
    required this.time,
    this.isCompleted = false,
    this.showRemoveAction = false,
  });
}

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({Key? key}) : super(key: key);

  @override
  _RemindersListScreenState createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  String _selectedDateKey = "Mon13";

  // --- Static Reminder Data (Keep as is) ---
  final List<Reminder> _reminders = [
    Reminder(
      id: "rem1",
      iconPath: "assets/images/ritalinpic.png",
      title: "Ritalin",
      details: "1 pill",
      time: "09:00 am",
      isCompleted: true,
    ),
    Reminder(
      id: "rem2",
      iconPath: "assets/images/sleeppic.png",
      title: "Sleep",
      time: "11:00 pm",
      isCompleted: false,
    ),
    Reminder(
      id: "rem3",
      iconPath: "assets/images/breathepic.png",
      title: "Breath",
      time: "05:30 pm",
      isCompleted: false,
      showRemoveAction: true,
    ),
    Reminder(
      id: "rem4",
      iconPath: "assets/images/walkpic.png",
      title: "Walk",
      time: "05:30 pm",
      isCompleted: false,
    ),
    Reminder(
      id: "rem5",
      iconPath: "assets/images/mindfulnesspic.png",
      title: "Mindfulness",
      time: "05:30 pm",
      isCompleted: false,
    ),
    Reminder(
      id: "rem6",
      iconPath: "assets/images/breakefreepic.png",
      title: "BreakFree",
      time: "05:30 pm",
      isCompleted: false,
    ),
  ];

  // --- State Management Functions (Keep as is) ---
  void _toggleReminderCompletion(String id) {
    /* ... existing code ... */
    int index = -1;
    setState(() {
      index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index].isCompleted = !_reminders[index].isCompleted;
      }
    });
    if (index != -1) {
      print("Toggled completion for $id to ${_reminders[index].isCompleted}");
    } else {
      print("Warning: Reminder with ID $id not found for toggling.");
    }
  }

  void _removeReminder(String id) {
    /* ... existing code ... */
    String removedTitle = '';
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        removedTitle = _reminders[index].title;
        _reminders.removeAt(index);
      }
    });
    if (removedTitle.isNotEmpty && mounted) {
      print("Removed reminder $id ($removedTitle)");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder "$removedTitle" removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addReminder() {
    /* ... existing code ... */
    setState(() {
      final newId = 'rem${DateTime.now().millisecondsSinceEpoch}';
      _reminders.add(
        Reminder(
          id: newId,
          iconPath: 'assets/images/medcuppic.png',
          title: 'New Task ${(_reminders.length + 1) - 5}',
          details: 'Just added',
          time: TimeOfDay.now().format(context),
          isCompleted: false,
          showRemoveAction: true,
        ),
      );
      print("Added new reminder with ID: $newId");
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New reminder added!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerImageHeight =
        screenHeight * 0.25; // Define header height

    return Scaffold(
      backgroundColor: kWhite, // White background for the main content area
      body: Stack(
        children: [
          // 1. Background Header Image (positioned, no overlay needed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerImageHeight,
              color:
                  kHeaderBlueTint, // Background color in case image fails/is transparent
              child: Image.asset(
                'assets/images/manybrainspic.png',
                fit: BoxFit.cover, // Cover the area
                alignment:
                    Alignment.center, // Center the image within the container
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading header image: $error");
                  // Fallback: show a colored container or placeholder icon
                  return Container(
                    color: kHeaderBlueTint,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        color: kWhite.withOpacity(0.5),
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Main Scrollable Content Area starting BELOW the header image
          // Use Padding to push the CustomScrollView down
          Padding(
            padding: EdgeInsets.only(
              top: headerImageHeight,
            ), // Start content below image
            child: CustomScrollView(
              slivers: <Widget>[
                // --- "Reminders" Title (Now part of scrollable content) ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20.0,
                      25.0,
                      20.0,
                      15.0,
                    ), // Adjust top padding as needed
                    child: Text(
                      'Reminders',
                      style: TextStyle(
                        fontFamily: 'Serif', // Use a serif font if available
                        fontSize: 30,
                        fontWeight:
                            FontWeight
                                .w600, // Slightly less bold than full bold
                        color:
                            kTitleColor, // Darker teal/blue title on white background
                      ),
                    ),
                  ),
                ),

                // --- Date Selector ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: SizedBox(
                      height: 65,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDateChip("Sun", "12", "Sun12", screenWidth),
                          _buildDateChip("Mon", "13", "Mon13", screenWidth),
                          _buildDateChip("Tue", "14", "Tue14", screenWidth),
                          _buildDateChip("Wed", "15", "Wed15", screenWidth),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- "Today" + Add Button ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20.0,
                      15.0,
                      20.0,
                      15.0,
                    ), // Adjusted padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryTeal,
                          ),
                        ),
                        InkWell(
                          onTap: _addReminder,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimaryTeal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.add, color: kWhite, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Reminders List (Keep logic as is) ---
                if (_reminders.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 60,
                            color: kGreyText.withOpacity(0.5),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No reminders!',
                            style: TextStyle(color: kGreyText),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap + to add one.',
                            style: TextStyle(color: kGreyText),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final reminder = _reminders[index];
                        if (reminder.showRemoveAction) {
                          return Dismissible(
                            key: Key(reminder.id),
                            direction: DismissDirection.endToStart,
                            onDismissed:
                                (direction) => _removeReminder(reminder.id),
                            background: _buildDismissibleBackground(),
                            child: _buildReminderItem(reminder),
                          );
                        } else {
                          return _buildReminderItem(reminder);
                        }
                      }, childCount: _reminders.length),
                    ),
                  ),

                // Bottom padding
                SliverPadding(padding: EdgeInsets.only(bottom: 90)),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar (Keep as is)
      bottomNavigationBar: BottomNavigationBar(
        /* ... existing code ... */
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kDarkTeal,
        selectedItemColor: kWhite,
        unselectedItemColor: kWhite.withOpacity(0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0 && ModalRoute.of(context)?.settings.name != '/') {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
        },
      ),
    );
  }

  // --- Helper Widgets (Keep as is) ---
  Widget _buildDismissibleBackground() {
    /* ... existing code ... */
    return Container(
      decoration: BoxDecoration(
        color: kRedRemove,
        borderRadius: BorderRadius.circular(15.0),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Remove',
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete_outline, color: kWhite),
        ],
      ),
    );
  }

  Widget _buildDateChip(
    String dayName,
    String dayNumber,
    String key,
    double screenWidth,
  ) {
    /* ... existing code ... */
    bool isSelected = _selectedDateKey == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateKey = key;
        });
        print("Selected Date: $key");
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryTeal : kGreyBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: kPrimaryTeal.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? kWhite : kDarkGreyText.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? kWhite : kDarkGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    /* ... existing code ... */
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: kLightBlueGrey,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: Image.asset(
                      reminder.iconPath,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (c, e, s) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[600],
                            ),
                          ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryTeal,
                          ),
                        ),
                        if (reminder.details != null &&
                            reminder.details!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              reminder.details!,
                              style: TextStyle(fontSize: 13, color: kGreyText),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            top:
                                (reminder.details != null &&
                                        reminder.details!.isNotEmpty)
                                    ? 0
                                    : 4.0,
                          ),
                          child: Text(
                            reminder.time,
                            style: TextStyle(fontSize: 13, color: kGreyText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  InkWell(
                    onTap: () => _toggleReminderCompletion(reminder.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: reminder.isCompleted ? kPrimaryTeal : kWhite,
                        border:
                            reminder.isCompleted
                                ? null
                                : Border.all(
                                  color: kGreyBackground.withOpacity(0.8),
                                  width: 1.5,
                                ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child:
                          reminder.isCompleted
                              ? Icon(Icons.check, color: kWhite, size: 24)
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
