// lib/screens/reminders_list_screen.dart
import 'package:flutter/material.dart';

// Basic placeholder for the screen based on your JSON structure
// You will need to build out the actual UI here later using the JSON details
class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({Key? key}) : super(key: key);

  @override
  _RemindersListScreenState createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  // --- Placeholder State (You'll manage real data here) ---
  String _selectedDate = "Mon 13"; // Default based on JSON
  // Add state for reminders list, completion status, etc.

  @override
  Widget build(BuildContext context) {
    // --- Basic Scaffold structure ---
    return Scaffold(
      // --- Header (Simplified AppBar for now) ---
      appBar: AppBar(
        // You might want a custom AppBar or Stack for the background image
        title: Text('Reminders'), // From JSON
        backgroundColor: Colors.teal[300], // Example color matching theme
        elevation: 0, // Less shadow
      ),

      // --- Body (Needs significant implementation) ---
      body: SingleChildScrollView(
        // Use SingleChildScrollView for potentially long list
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for Header Image (if not in AppBar)
            // Container(height: 100, color: Colors.teal[400], child: Center(child: Text("Header Image Area"))),

            // Placeholder for Date Selector
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDateChip("Sun", "12", false),
                  _buildDateChip("Mon", "13", true), // Selected
                  _buildDateChip("Tue", "14", false),
                  _buildDateChip("Wed", "15", false),
                ],
              ),
            ),

            // Placeholder for "Today" + Add Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[600]),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle,
                        color: Colors.teal[500], size: 30),
                    onPressed: () {
                      print("Add Reminder Tapped");
                      // Implement add reminder logic/navigation
                    },
                  ),
                ],
              ),
            ),

            // Placeholder for Reminders List (Needs proper widget)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Reminder List Items will go here...'),
              // Replace with a ListView.builder and custom ReminderItem widgets
            ),
            _buildReminderItem("Ritalin", "1 pill", "09:00 am", true),
            _buildReminderItem("Sleep", null, "11:00 pm", false),
            _buildReminderItem("Breath", null, "05:30 pm", false),
            _buildReminderItem("Walk", null, "05:30 pm", false),
            // ... add other items
          ],
        ),
      ),

      // --- Bottom Navigation Bar (Placeholder) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Index 1 corresponds to the 'Reminders' (clock) icon
        type: BottomNavigationBarType
            .fixed, // Shows labels even when not selected
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Reminders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Tasks'), // Or Journal
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: 'Learn'), // Or Resources
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
          print("Tapped nav item: $index");
          if (index == 0) {
            Navigator.popUntil(
                context, ModalRoute.withName('/')); // Go back to Home
          }
          // Add navigation for other tabs if needed
        },
      ),
    );
  }

  // --- Helper Widgets (Placeholders/Examples) ---

  Widget _buildDateChip(String dayName, String dayNumber, bool isSelected) {
    return ChoiceChip(
      label: Column(children: [
        Text(dayName),
        Text(dayNumber, style: TextStyle(fontWeight: FontWeight.bold))
      ]),
      selected: isSelected,
      onSelected: (selected) {
        // Handle date selection logic
        setState(() {
          _selectedDate = "$dayName $dayNumber"; // Update state (simplified)
        });
      },
      selectedColor: Colors.teal[400],
      backgroundColor: Colors.grey[300],
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black54),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    );
  }

  Widget _buildReminderItem(
      String title, String? details, String time, bool isCompleted) {
    // This is a VERY basic representation. You'll want icons, layout, etc.
    // You'll also need to handle the swipe action for "Remove"
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        // leading: Icon(Icons.medication), // Placeholder for actual icon
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details != null) Text(details),
            Text(time),
          ],
        ),
        trailing: Checkbox(
          value: isCompleted,
          onChanged: (bool? value) {
            // Handle completion state change
            print("Checkbox for $title changed to $value");
            // You'll need to update the state of the specific reminder
          },
          activeColor: Colors.teal[500],
        ),
      ),
    );
  }
}
