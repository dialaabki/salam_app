// File: lib/screens/progress/UserProgressHistoryScreen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math; // Only if you use math.Random, otherwise can remove
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Ensure path is correct for your bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart';
// Import main for route constants if used for navigation from here
// import '../../main.dart'; // Or remove if not using MyApp constants here

// --- Define Colors (Consider moving to a central theme file or using Theme.of(context)) ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white; // Consider Theme.of(context).colorScheme.surface
const Color separatorColor = Colors.black26;
const Color activityBarColor = Color(0xFF4CAF50);
// const Color remindersBarColor = Colors.teal; // Not used in Option 1


class UserProgressHistoryScreen extends StatefulWidget {
  const UserProgressHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserProgressHistoryScreen> createState() => _UserProgressHistoryScreenState();
}

class _UserProgressHistoryScreenState extends State<UserProgressHistoryScreen> {
  // --- State Variables ---
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  bool _isLoadingMood = true;
  bool _isLoadingActivities = true;
  bool _isLoadingReminders = true;

  Map<String, double> _averageMoods = {};
  Map<String, double> _averageActivityDurations = {};
  Map<String, int> _totalRemindersCheckedPerDayMap = {};
  double _averageRemindersCheckedPerDay = 0.0;

  String _errorMessage = '';

  final double _targetActivityDurationMinutes = 30.0;
  final double _targetRemindersCompletedPerDay = 5.0; // Example target for feedback

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    if (_errorMessage.isNotEmpty) {
       setState(() => _errorMessage = '');
    }
    setState(() {
       _isLoadingMood = true;
       _isLoadingActivities = true;
       _isLoadingReminders = true;
    });
    await Future.wait([
       _fetchAndCalculateMoodAverages(),
       _fetchAndCalculateActivityAverages(),
       _fetchAndCalculateRemindersChecked(),
    ]);
  }

  Future<void> _fetchAndCalculateMoodAverages() async {
      if (!mounted) return;
      print("PROGRESS: Fetching mood averages...");
      if (!_isLoadingMood && mounted) {
        setState(() => _isLoadingMood = true);
      }
      Map<String, double> calculatedMoodAverages = {};
      Map<String, List<int>> categoryRatingsList = {};
      String currentErrorMessage = '';
      final user = _auth.currentUser;
      if (user == null) {
        currentErrorMessage = "Please log in to view mood progress.";
      } else {
        final DateTime endOfDay = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
        final DateTime startOfDay = DateTime(_startDate.year, _startDate.month, _startDate.day);
        try {
          QuerySnapshot querySnapshot = await _firestore.collection('daily_moods')
              .where('userId', isEqualTo: user.uid)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .get();
          for (var doc in querySnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              data.forEach((key, value) {
                if (key.startsWith('ratings.') && key.length > 'ratings.'.length) {
                  String category = key.substring('ratings.'.length);
                  int? ratingInt = _parseRating(value);
                  if (ratingInt != null && ratingInt > 0) {
                    categoryRatingsList.putIfAbsent(category, () => []);
                    categoryRatingsList[category]!.add(ratingInt);
                  }
                }
              });
            }
          }
          categoryRatingsList.forEach((category, ratings) {
            if (ratings.isNotEmpty) {
              double sum = ratings.fold(0.0, (prev, el) => prev + el);
              calculatedMoodAverages[category] = sum / ratings.length;
            }
          });
        } catch (e) {
          print("PROGRESS: Error fetching/calculating mood averages: $e");
          currentErrorMessage = "Error loading mood data: ${e.toString()}";
          if (e is FirebaseException && e.code == 'failed-precondition') { currentErrorMessage = "Database index required for moods. Check logs."; }
        }
      }
      if (mounted) {
        setState(() {
          _averageMoods = calculatedMoodAverages;
          _isLoadingMood = false;
          if (currentErrorMessage.isNotEmpty) { _errorMessage = _errorMessage.isEmpty ? currentErrorMessage : "$_errorMessage\n$currentErrorMessage"; }
        });
      }
  }

  int? _parseRating(dynamic ratingValue){
    if (ratingValue is int) return ratingValue;
    if (ratingValue is double) return ratingValue.toInt();
    if (ratingValue is String) return int.tryParse(ratingValue);
    return null;
  }

  Future<void> _fetchAndCalculateActivityAverages() async {
      if (!mounted) return;
      print("PROGRESS: Fetching activity averages...");
      if (!_isLoadingActivities && mounted) { setState(() => _isLoadingActivities = true); }
      Map<String, double> calculatedActivityAverages = {};
      Map<String, double> totalDurations = {};
      Map<String, Set<String>> daysPerformed = {};
      String currentErrorMessage = '';
      final user = _auth.currentUser;
      if (user == null) {
        currentErrorMessage = "Please log in to view activity progress.";
      } else {
        final DateTime endOfDay = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
        final DateTime startOfDay = DateTime(_startDate.year, _startDate.month, _startDate.day);
        try {
          QuerySnapshot querySnapshot = await _firestore.collection('daily_activity_summary')
              .where('userId', isEqualTo: user.uid)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .get();
          for (var doc in querySnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            final Map<String, dynamic>? durationsMap = data?['durations'] as Map<String, dynamic>?;
            final Timestamp? completedAt = data?['date'] as Timestamp?;
            if (durationsMap != null && completedAt != null) {
              String dateString = DateFormat('yyyy-MM-dd').format(completedAt.toDate());
              durationsMap.forEach((activityName, durationValue) {
                double? durationDouble;
                if(durationValue is int) durationDouble = durationValue.toDouble();
                else if (durationValue is double) durationDouble = durationValue;
                if (activityName != null && durationDouble != null) {
                  totalDurations[activityName] = (totalDurations[activityName] ?? 0.0) + durationDouble;
                  daysPerformed.putIfAbsent(activityName, () => {}).add(dateString);
                }
              });
            }
          }
          totalDurations.forEach((activityName, totalDuration) {
            int numDays = daysPerformed[activityName]?.length ?? 1;
            if (numDays > 0) { calculatedActivityAverages[activityName] = totalDuration / numDays; }
          });
        } catch (e) {
          print("PROGRESS: Error fetching/calculating activity averages: $e");
          currentErrorMessage = "Error loading activity data: ${e.toString()}";
           if (e is FirebaseException && e.code == 'failed-precondition') { currentErrorMessage = "Database index required for activity summaries. Check logs."; }
        }
      }
      if (mounted) {
        setState(() {
          _averageActivityDurations = calculatedActivityAverages;
          _isLoadingActivities = false;
          if (currentErrorMessage.isNotEmpty) { _errorMessage = _errorMessage.isEmpty ? currentErrorMessage : "$_errorMessage\n$currentErrorMessage"; }
        });
      }
  }

  Future<void> _fetchAndCalculateRemindersChecked() async {
    if (!mounted) return;
    print("PROGRESS: Fetching reminders checked counts...");
    if (!_isLoadingReminders && mounted) { setState(() => _isLoadingReminders = true); }
    Map<String, int> calculatedTotalRemindersCheckedPerDay = {};
    double calculatedAverageRemindersCheckedPerDay = 0.0;
    String currentErrorMessage = '';
    final user = _auth.currentUser;
    if (user == null) {
      currentErrorMessage = "Please log in to view reminder progress.";
    } else {
      final DateTime endOfDayForQuery = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
      final DateTime startOfDayForQuery = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final String startDateString = DateFormat('yyyy-MM-dd').format(startOfDayForQuery);
      final String endDateString = DateFormat('yyyy-MM-dd').format(endOfDayForQuery);
      try {
        QuerySnapshot remindersSnapshot = await _firestore.collection('reminders').where('userId', isEqualTo: user.uid).get();
        Map<String, int> dailyCounts = {};
        for (var reminderDoc in remindersSnapshot.docs) {
          QuerySnapshot completionsSnapshot = await _firestore.collection('reminders').doc(reminderDoc.id).collection('dailyCompletions')
              .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateString)
              .where(FieldPath.documentId, isLessThanOrEqualTo: endDateString)
              .get();
          for (var completionDoc in completionsSnapshot.docs) {
            String dateString = completionDoc.id;
            dailyCounts[dateString] = (dailyCounts[dateString] ?? 0) + 1;
          }
        }
        calculatedTotalRemindersCheckedPerDay = dailyCounts;
        if (dailyCounts.isNotEmpty) {
          int totalCheckedInPeriod = 0;
          dailyCounts.forEach((date, count) { totalCheckedInPeriod += count; });
          int numberOfDaysInSelectedRange = _endDate.difference(_startDate).inDays + 1;
          if (numberOfDaysInSelectedRange > 0) {
            calculatedAverageRemindersCheckedPerDay = totalCheckedInPeriod / numberOfDaysInSelectedRange;
          } else {
             calculatedAverageRemindersCheckedPerDay = totalCheckedInPeriod.toDouble();
          }
        }
      } catch (e) {
        print("PROGRESS: Error fetching/calculating reminders checked: $e");
        currentErrorMessage = "Error loading reminder completion data: ${e.toString()}";
         if (e is FirebaseException && e.code == 'failed-precondition') { currentErrorMessage = "Database index might be required. Check logs."; }
      }
    }
    if (mounted) {
      setState(() {
        _totalRemindersCheckedPerDayMap = calculatedTotalRemindersCheckedPerDay;
        _averageRemindersCheckedPerDay = calculatedAverageRemindersCheckedPerDay;
        _isLoadingReminders = false;
        if (currentErrorMessage.isNotEmpty) { _errorMessage = _errorMessage.isEmpty ? currentErrorMessage : "$_errorMessage\n$currentErrorMessage"; }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
     if(_isLoadingMood || _isLoadingActivities || _isLoadingReminders) return;
     final DateTime firstAllowedDate = DateTime(2023);
     final DateTime lastAllowedDate = DateTime.now();
     final DateTime initialPickerDate = isStartDate
        ? (_startDate.isBefore(firstAllowedDate) ? firstAllowedDate : _startDate)
        : (_endDate.isAfter(lastAllowedDate) ? lastAllowedDate : _endDate);
     final DateTime? picked = await showDatePicker(
        context: context, initialDate: initialPickerDate, firstDate: firstAllowedDate, lastDate: lastAllowedDate,
        builder: (context, child) {
          return Theme( data: Theme.of(context).copyWith( colorScheme: Theme.of(context).colorScheme.copyWith( primary: mainAppColor, onPrimary: Colors.white, ),), child: child!,);
        },
     );
     if (picked != null && mounted) {
        bool dateChanged = false; DateTime tempStartDate = _startDate; DateTime tempEndDate = _endDate;
        if (isStartDate) { if (picked != _startDate) { tempStartDate = picked; if (tempEndDate.isBefore(tempStartDate)) { tempEndDate = tempStartDate; } dateChanged = true; }
        } else { if(picked != _endDate) { tempEndDate = picked; if (tempStartDate.isAfter(tempEndDate)) { tempStartDate = tempEndDate; } dateChanged = true; } }
        if (dateChanged) { setState(() { _startDate = tempStartDate; _endDate = tempEndDate; }); _fetchAllData(); }
     }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoadingAny = _isLoadingMood || _isLoadingActivities || _isLoadingReminders;
    final theme = Theme.of(context); // Get theme for consistent colors

    return Scaffold(
      backgroundColor: theme.colorScheme.primary, // Use theme color
      appBar: AppBar(
        title: const Text("Progress History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary, // Use theme color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell( onTap: isLoadingAny ? null : () => _selectDate(context, true), child: _buildDateDisplay("From", DateFormat('MMM d, yyyy').format(_startDate)),),
                IconButton( icon: const Icon(Icons.refresh, color: Colors.white), tooltip: 'Refresh Data', onPressed: isLoadingAny ? null : _fetchAllData,),
                InkWell( onTap: isLoadingAny ? null : () => _selectDate(context, false), child: _buildDateDisplay("To", DateFormat('MMM d, yyyy').format(_endDate)),),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // Use theme color
                borderRadius: const BorderRadius.only( topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0) ),
              ),
              child: RefreshIndicator(
                onRefresh: _fetchAllData,
                color: theme.colorScheme.primary, // Use theme color
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage.isNotEmpty && _averageMoods.isEmpty && _averageActivityDurations.isEmpty && _averageRemindersCheckedPerDay == 0.0 && _totalRemindersCheckedPerDayMap.isEmpty)
                          Padding( padding: const EdgeInsets.only(bottom: 20.0), child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),),
                        _buildSectionTitle("Mood tracking"), const SizedBox(height: 20),
                        _isLoadingMood
                            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: CircularProgressIndicator()))
                            : _averageMoods.isEmpty && !_errorMessage.toLowerCase().contains("mood")
                                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30.0), child: Text("No mood data for this period.", style: TextStyle(color: theme.textTheme.bodySmall?.color))))
                                : _buildMoodAveragesDisplay(),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Activity Progress (Avg Daily Duration)"), const SizedBox(height: 20),
                        _isLoadingActivities
                            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: CircularProgressIndicator()))
                            : _averageActivityDurations.isEmpty && !_errorMessage.toLowerCase().contains("activity")
                                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30.0), child: Text("No activities for this period.", style: TextStyle(color: theme.textTheme.bodySmall?.color))))
                                : _buildActivityAveragesDisplay(),
                        const SizedBox(height: 30),
                        _buildSectionTitle("Reminders Completed (Avg Daily)"), const SizedBox(height: 20),
                        _isLoadingReminders
                            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: CircularProgressIndicator()))
                            : _averageRemindersCheckedPerDay == 0.0 && _totalRemindersCheckedPerDayMap.isEmpty && !_errorMessage.toLowerCase().contains("reminder")
                                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30.0), child: Text("No reminders completed in this period.", style: TextStyle(color: theme.textTheme.bodySmall?.color))))
                                : _buildRemindersCheckedDisplay(), // Use the new display method
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodAveragesDisplay() {
    if (_averageMoods.isEmpty && !_isLoadingMood) return const SizedBox.shrink();
    List<String> sortedCategories = _averageMoods.keys.toList()..sort();
    final theme = Theme.of(context);
    return Column(
      children: sortedCategories.map((category) {
        double average = _averageMoods[category]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded( flex: 2, child: Text( "$category:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis,),),
              const SizedBox(width: 10),
              Expanded( flex: 3, child: Row( mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text( average.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),),
                    const SizedBox(width: 4), const Icon(Icons.star_rounded, color: Colors.amber, size: 20), const SizedBox(width: 10),
                    Expanded( child: Container( height: 10, constraints: const BoxConstraints(minWidth: 50), decoration: BoxDecoration( color: theme.dividerColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5),),
                        child: Align( alignment: Alignment.centerLeft, child: FractionallySizedBox( widthFactor: (average / 5.0).clamp(0.0, 1.0),
                            child: Container( decoration: BoxDecoration( color: _getBarColor(average), borderRadius: BorderRadius.circular(5),),),),),),),],),),],),);}).toList(),);
  }

  Widget _buildActivityAveragesDisplay() {
     if (_averageActivityDurations.isEmpty && !_isLoadingActivities) return const SizedBox.shrink();
     List<String> sortedActivities = _averageActivityDurations.keys.toList()..sort();
     final theme = Theme.of(context);
     return Column(
       children: sortedActivities.map((activityName) {
         double averageDuration = _averageActivityDurations[activityName]!;
         double progressFraction = (averageDuration / _targetActivityDurationMinutes).clamp(0.0, 1.0);
         return Padding(
           padding: const EdgeInsets.symmetric(vertical: 8.0),
           child: Row(
             children: [
               Expanded( flex: 2, child: Text( "$activityName:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis,),),
               const SizedBox(width: 10),
               Expanded( flex: 3, child: Row( mainAxisAlignment: MainAxisAlignment.end, children: [
                     Text( "${averageDuration.toStringAsFixed(0)} min/day", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),), const SizedBox(width: 10),
                     Expanded( child: Container( height: 10, constraints: const BoxConstraints(minWidth: 50), decoration: BoxDecoration( color: theme.dividerColor.withOpacity(0.3), borderRadius: BorderRadius.circular(5),),
                         child: Align( alignment: Alignment.centerLeft, child: FractionallySizedBox( widthFactor: progressFraction,
                             child: Container( decoration: BoxDecoration( color: activityBarColor, borderRadius: BorderRadius.circular(5),),),),),),),],),),],),);}).toList(),);
  }

  // --- Updated Widget to display reminders checked (Simple Text with Icon & Context) ---
  Widget _buildRemindersCheckedDisplay() {
    if (_isLoadingReminders) return const SizedBox.shrink(); // Already handled by loading indicator
    if (_averageRemindersCheckedPerDay == 0.0 && _totalRemindersCheckedPerDayMap.isEmpty) {
       // "No reminders completed" message is handled in the main build logic
       return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    Color valueColor = theme.colorScheme.primary; // Default
    String feedbackText = "Good job staying on track!";

    if (_averageRemindersCheckedPerDay > 0 && _averageRemindersCheckedPerDay < (_targetRemindersCompletedPerDay * 0.5)) {
        valueColor = Colors.orange.shade700;
        feedbackText = "Keep pushing, consistency is key!";
    } else if (_averageRemindersCheckedPerDay >= (_targetRemindersCompletedPerDay * 0.8)) {
        valueColor = Colors.green.shade600;
        feedbackText = "Excellent consistency!";
    } else if (_averageRemindersCheckedPerDay > 0) {
        valueColor = Colors.blue.shade600; // Or theme.colorScheme.secondary
        feedbackText = "Making good progress!";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
Icon(Icons.playlist_add_check_rounded, color: valueColor, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_averageRemindersCheckedPerDay.toStringAsFixed(1)} Reminders / Day",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                if (_averageRemindersCheckedPerDay > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      feedbackText,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(double average) {
    if (average <= 1.5) return Colors.red.shade400;
    if (average <= 2.5) return Colors.orange.shade400;
    if (average <= 3.5) return Colors.yellow.shade700;
    if (average <= 4.5) return Colors.lightGreen.shade500;
    return Colors.green.shade600;
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface, // Use theme color
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: theme.dividerColor.withOpacity(0.5), thickness: 1),
      ],
    );
   }

} // End of _UserProgressHistoryScreenState