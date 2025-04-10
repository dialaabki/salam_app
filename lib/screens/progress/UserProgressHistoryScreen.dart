import 'package:flutter/material.dart';
import 'dart:math' as math; // For Pie chart/progress simulation
import '../../../widgets/bottom_nav_bar.dart';
import '../../../main.dart'; // For theme colors if needed

// --- Define Colors ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white;
const Color separatorColor = Colors.black26;
const Color progressColor = Color(0xFF00BCD4); // Cyan for progress

// --- Asset Paths ---
const String moodGaugePlaceholder = "assets/images/mood_gauge_placeholder.png"; // ** REPLACE **
const String moodSmileyPlaceholder = "assets/images/mood_smiley_placeholder.png"; // ** REPLACE **

class UserProgressHistoryScreen extends StatelessWidget {
  const UserProgressHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder progress value (0.0 to 1.0)
    final double activityProgress = 0.66;

    return Scaffold(
      backgroundColor: mainAppColor,
      appBar: AppBar(
        title: const Text("Progress History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: mainAppColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body: Column( // Use column to stack top colored area and white card
        children: [
          // --- Date Range Selector Area ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TODO: Implement actual date pickers
                _buildDateDisplay("From", "Jun 10, 2024"),
                _buildDateDisplay("To", "Jun 17, 2024"),
              ],
            ),
          ),
          // --- White Content Container ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: lightBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Mood Tracking Section ---
                      _buildSectionTitle("Mood tracking"),
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset( // Placeholder Gauge
                          moodGaugePlaceholder,
                          height: 100, // Adjust size
                           errorBuilder: (c,e,s) => Text("Gauge Error"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset( // Placeholder Smiley
                          moodSmileyPlaceholder,
                          height: 40, // Adjust size
                           errorBuilder: (c,e,s) => Text("Smiley Error"),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Activity Progress Section ---
                      _buildSectionTitle("Activity Progress"),
                      const SizedBox(height: 30),
                      Center(
                        // Placeholder for Circular Progress
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: activityProgress, // 0.0 to 1.0
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                              Text(
                                "${(activityProgress * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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

  Widget _buildDateDisplay(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

   Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
           title,
           style: TextStyle(
             color: lightTextColor,
             fontSize: 16,
             fontWeight: FontWeight.w500,
           ),
         ),
         const SizedBox(height: 4),
         const Divider(color: separatorColor, thickness: 0.8),
      ],
    );
   }
}