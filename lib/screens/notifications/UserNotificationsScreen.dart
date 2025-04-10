import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../main.dart';

// --- Define Colors ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white;
const Color cardBgColor = Color(0xFFF0F8FF); // AliceBlue or similar light color

// --- Asset Paths ---
const String iconWalkPath = "assets/images/icon_walk.png"; // Reuse reminder icon
const String notificationProgressPlaceholder = "assets/images/notification_progress_placeholder.png"; // ** REPLACE **
const String notificationVideoPlaceholder = "assets/images/notification_video_placeholder.png"; // ** REPLACE **


class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({Key? key}) : super(key: key);

  // Placeholder Notification Data
  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'Its time to do your walking activity',
      'image': iconWalkPath, // Use walk icon
      'description': 'Walk',
      'time': 'Now',
      'isActivity': true, // Flag for specific styling if needed
    },
    {
      'title': 'Your weekly progress has been sent to your doctor',
      'image': notificationProgressPlaceholder, // Placeholder for doctor/graph
      'description': '', // No extra description needed
      'time': '5 minutes ago',
      'isActivity': false,
    },
     {
      'title': 'A new video about Anxiety Check it out',
      'image': notificationVideoPlaceholder, // Placeholder for video thumbnail
      'description': 'The Anxiety Fight Flight Freeze Response',
      'time': '15 minutes ago',
      'isActivity': false,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: mainAppColor,
       appBar: AppBar(
        title: Row( // Title with Icon
          children: const [
            Icon(Icons.notifications_active_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: mainAppColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body: Container( // Use Container to apply border radius
          width: double.infinity,
          height: double.infinity, // Ensure it fills available space
          decoration: const BoxDecoration(
            color: lightBgColor, // White background for list area
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(20.0), // Padding around the list
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(
                title: notification['title'],
                imagePath: notification['image'],
                description: notification['description'],
                time: notification['time'],
                isActivity: notification['isActivity'] ?? false,
              );
            },
          ),
        ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String imagePath,
    required String description,
    required String time,
    bool isActivity = false,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: cardBgColor, // Light background for card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Title (Optional - design seems to use description as main text)
             if (!isActivity && title.isNotEmpty) ...[
               Text(
                 title,
                 style: TextStyle(
                   fontWeight: FontWeight.w600,
                   color: darkTextColor,
                   fontSize: 15,
                 ),
               ),
               const SizedBox(height: 10),
             ],
             // Content Row (Image + Description/Activity Name)
             Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Image.asset(
                       imagePath,
                       height: isActivity ? 50 : 60, // Adjust size based on type
                       width: isActivity ? 50 : 100,
                       fit: isActivity ? BoxFit.contain : BoxFit.cover,
                       errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, color: Colors.grey),
                   ),
                   const SizedBox(width: 15),
                   Expanded( // Allow text to wrap
                      child: Text(
                          isActivity ? description : title, // Show activity name or title here
                          style: TextStyle(
                              fontWeight: isActivity ? FontWeight.bold : FontWeight.w500,
                              color: isActivity ? mainAppColor : darkTextColor,
                              fontSize: isActivity ? 20 : 16,
                          ),
                      ),
                   ),
                ],
             ),
             const SizedBox(height: 8),
             // Timestamp
             Align(
                alignment: Alignment.bottomRight,
                child: Text(
                   time,
                   style: TextStyle(
                      color: lightTextColor,
                      fontSize: 12,
                   ),
                ),
             ),
          ],
        ),
      ),
    );
  }
}