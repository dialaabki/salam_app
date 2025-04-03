// File: lib/screens/activities/breakfree_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
// Ensure this path is correct for your project structure
import '../../widgets/bottom_nav_bar.dart';

enum StreakStatus { yes, no, empty }

class BreakFreeScreen extends StatefulWidget {
  // static const routeName = '/breakFree'; // Optional

  @override
  _BreakFreeScreenState createState() => _BreakFreeScreenState();
}

class _BreakFreeScreenState extends State<BreakFreeScreen> {
  List<StreakStatus> weekDisplayData = [];
  int totalStreak = 0;
  DateTime? lastAnswerDate;
  bool answeredToday = false;
  bool isLoading = true;
  Timer? _navTimer; // Only needed if passed to AppBottomNavBar

  static const String _streakKey = 'breakFree_totalStreak';
  static const String _lastDateKey = 'breakFree_lastAnswerDate';
  static const String _weekDataKey = 'breakFree_weekDisplayData_v2';

  final String fireIconPath = 'assets/images/fire_icon.png';
  final String extinguisherIconPath = 'assets/images/extinguisher_icon.png';
  final String freedomImagePath = 'assets/images/freedom.png';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      totalStreak = prefs.getInt(_streakKey) ?? 0;

      String? dateString = prefs.getString(_lastDateKey);
      if (dateString != null) {
        lastAnswerDate = DateTime.tryParse(dateString);
      } else {
        lastAnswerDate = null;
      }

      String savedWeekData = prefs.getString(_weekDataKey) ?? '';
      if (savedWeekData.isNotEmpty) {
         List<String> items = savedWeekData.split(',');
         weekDisplayData = items.map((item) {
           try {
             int index = int.parse(item);
             if (index >= 0 && index < StreakStatus.values.length) {
                return StreakStatus.values[index];
             }
             return StreakStatus.empty;
           } catch (e) {
             print("Error parsing week data item: $item, Error: $e");
             return StreakStatus.empty;
           }
         }).toList();
         if (weekDisplayData.length > 7) {
            weekDisplayData = weekDisplayData.sublist(weekDisplayData.length - 7);
         }
      } else {
         weekDisplayData = [];
      }

      _checkIfAnsweredToday();

    } catch (e) {
       print("Error loading data: $e");
       weekDisplayData = [];
       totalStreak = 0;
       lastAnswerDate = null;
       answeredToday = false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_streakKey, totalStreak);
      if (lastAnswerDate != null) {
        await prefs.setString(_lastDateKey, lastAnswerDate!.toIso8601String());
      } else {
         await prefs.remove(_lastDateKey);
      }
      String weekDataString = weekDisplayData.map((status) => status.index.toString()).join(',');
      await prefs.setString(_weekDataKey, weekDataString);
      print("Data Saved: Streak=$totalStreak, LastDate=$lastAnswerDate, WeekData=$weekDataString");
    } catch (e) {
       print("Error saving data: $e");
    }
  }

  void _checkIfAnsweredToday() {
    if (lastAnswerDate == null) {
      answeredToday = false;
      return;
    }
    final now = DateTime.now();
    answeredToday = lastAnswerDate!.year == now.year &&
                    lastAnswerDate!.month == now.month &&
                    lastAnswerDate!.day == now.day;
  }

  Future<void> _handleAnswer(bool feltInControl) async {
    if (answeredToday || isLoading || !mounted) return;

    final now = DateTime.now();
    final newStatus = feltInControl ? StreakStatus.yes : StreakStatus.no;

    setState(() {
      if (feltInControl) {
        totalStreak++;
      } else {
        totalStreak = 0;
      }

      if (weekDisplayData.length >= 7) {
        weekDisplayData.removeAt(0);
      }
      weekDisplayData.add(newStatus);

      answeredToday = true;
      lastAnswerDate = now;
    });

    await _saveData();
  }

  Widget _buildStreakIcons() {
    const double iconSize = 40.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        Widget iconWidget;
        if (index < weekDisplayData.length) {
           StreakStatus status = weekDisplayData[index];
           switch (status) {
             case StreakStatus.yes:
               iconWidget = Image.asset(fireIconPath, width: iconSize, height: iconSize, key: ValueKey('yes_$index'));
               break;
             case StreakStatus.no:
                iconWidget = Image.asset(extinguisherIconPath, width: iconSize, height: iconSize, key: ValueKey('no_$index'));
               break;
             case StreakStatus.empty:
             // ignore: unreachable_switch_default
             default:
                 // This case should ideally not be reached if data exists
                 // If it does, render an empty circle as a fallback
                 iconWidget = Container(
                   width: iconSize,
                   height: iconSize,
                   key: ValueKey('fallback_empty_$index'),
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.white,
                     border: Border.all(color: Colors.grey.shade400, width: 1.5)
                   ),
                 );
                 break;
          }
        } else {
            iconWidget = Container(
             width: iconSize,
             height: iconSize,
             key: ValueKey('empty_$index'),
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: Colors.white,
               border: Border.all(color: Colors.grey.shade400, width: 1.5)
             ),
           );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: iconWidget,
        );
      }),
    );
  }

  Widget _buildStreakText() {
    return Text(
      "${totalStreak.toString().padLeft(2,'0')} - DAY STREAK",
      style: GoogleFonts.ewert(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E4B5F),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuestionCard() {
    final Color cardColor = Color(0xFF3E8A9A);
    final Color buttonTextColor = cardColor;
    final Color buttonBgColor = Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Text(
            'Did you feel in control today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '(No worries if not, tomorrow is a new day!)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: answeredToday ? null : () => _handleAnswer(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBgColor,
                  disabledBackgroundColor: buttonBgColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 12),
                ),
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 16, color: buttonTextColor, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: answeredToday ? null : () => _handleAnswer(false),
                style: ElevatedButton.styleFrom(
                   backgroundColor: buttonBgColor,
                   disabledBackgroundColor: buttonBgColor.withOpacity(0.5),
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 12),
                ),
                 child: Text(
                  'No',
                  style: TextStyle(fontSize: 16, color: buttonTextColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    return Column(
      children: [
        Text(
          'Keep Going, Unlock Your Milestones!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E4B5F),
          ),
        ),
        SizedBox(height: 25),
        Image.asset(
          freedomImagePath,
          height: 60,
           errorBuilder: (context, error, stackTrace) {
             print("Error loading image: $freedomImagePath, Error: $error");
             return Container(
                height: 60,
                child: Icon(Icons.celebration_outlined, size: 40, color: Colors.grey),
             );
           },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainContentBgColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/breakfree_bg.png',
              fit: BoxFit.cover,
               alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainContentBgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.0),
                      ),
                    ),
                    child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                         padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
                         child: Column(
                           children: [
                             _buildStreakIcons(),
                             SizedBox(height: 15),
                             _buildStreakText(),
                             SizedBox(height: 25),
                             _buildQuestionCard(),
                             SizedBox(height: 35),
                             _buildMilestones(),
                             SizedBox(height: 20),
                           ],
                         ),
                      ),
                  ),
                ),
              ],
            ),
          ),

          // --- ADDED Back Button ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 5, // Position below status bar
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, // Or Icons.arrow_back
                color: Colors.white, // White color for visibility on background
                shadows: [BoxShadow(color: Colors.black54, blurRadius: 3)], // Shadow for contrast
              ),
              tooltip: 'Back to Activities',
              onPressed: () {
                Navigator.pop(context); // Simple pop to go back one screen
              },
            ),
          ),
          // --- END Back Button ---

        ],
      ),
      // --- FIXED Bottom Nav Bar Call ---
      // Use the AppBottomNavBar class constructor
      bottomNavigationBar: AppBottomNavBar(navigationTimer: _navTimer),
      // --- END FIX ---
    );
  }
}