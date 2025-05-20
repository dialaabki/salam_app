// lib/screens/activities/log_nightly_sleep_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// ENSURE THIS IMPORT PATH IS CORRECT FOR YOUR PROJECT STRUCTURE
import 'SleepActivityScreen.dart'; // Replace 'flutter_application_2' with your actual package name

class LogNightlySleepScreen extends StatefulWidget {
  const LogNightlySleepScreen({Key? key}) : super(key: key);

  @override
  _LogNightlySleepScreenState createState() => _LogNightlySleepScreenState();
}

class _LogNightlySleepScreenState extends State<LogNightlySleepScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  bool _isSaving = false;
  bool _saveOperationCompletedSuccessfully = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get _canSaveChanges {
    final duration = _calculateSleepDuration();
    return _bedTime != null && _wakeTime != null && duration != null && duration > 0 && duration <= 24;
  }

  Future<void> _pickDate(BuildContext context) async {
    if (_isSaving || _saveOperationCompletedSuccessfully) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Select Wake-up Morning',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF4DB6AC),
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickTime(BuildContext context, bool isBedTime) async {
    if (_isSaving || _saveOperationCompletedSuccessfully) return;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? const TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 7, minute: 0)),
      helpText: isBedTime ? 'Select Bed Time' : 'Select Wake Up Time',
      builder: (context, child) {
        final Color selectedNumberColorOnDial = Colors.tealAccent.shade200;
        final Color clockDialUnselectedNumberColor = Colors.white.withOpacity(0.8);
        final Color clockHandColor = Colors.tealAccent.shade400;
        final Color timeDisplayHeaderColor = Colors.white;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: selectedNumberColorOnDial,
                  onPrimary: const Color(0xFF1D3A3A),
                  surface: const Color(0xFF22224A),
                  onSurface: Colors.white,
                ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF2D2D5A).withOpacity(0.98),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? selectedNumberColorOnDial
                      : timeDisplayHeaderColor.withOpacity(0.7)),
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? selectedNumberColorOnDial.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1)),
              dialHandColor: clockHandColor,
              dialBackgroundColor: const Color(0xFF3A3A6A),
              dialTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? selectedNumberColorOnDial
                      : clockDialUnselectedNumberColor),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? selectedNumberColorOnDial
                      : timeDisplayHeaderColor.withOpacity(0.8)),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? selectedNumberColorOnDial.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1)),
              dayPeriodBorderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              entryModeIconColor: selectedNumberColorOnDial.withOpacity(0.8),
              helpTextStyle: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
              cancelButtonStyle:
                  TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.8)),
              confirmButtonStyle: TextButton.styleFrom(foregroundColor: selectedNumberColorOnDial),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? tod) {
    if (tod == null) return 'Not Set';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat.jm().format(dt);
  }

  double? _calculateSleepDuration() {
    if (_bedTime == null || _wakeTime == null) return null;
    DateTime bedFullDateTime;
    DateTime wakeFullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );
    if ((_bedTime!.hour > _wakeTime!.hour &&
            !(_bedTime!.period == DayPeriod.am && _wakeTime!.period == DayPeriod.pm)) ||
        (_bedTime!.period == DayPeriod.pm && _wakeTime!.period == DayPeriod.am)) {
      bedFullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day - 1,
        _bedTime!.hour,
        _bedTime!.minute,
      );
    } else {
      bedFullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _bedTime!.hour,
        _bedTime!.minute,
      );
      if (bedFullDateTime.isAfter(wakeFullDateTime)) {
        bedFullDateTime = bedFullDateTime.subtract(const Duration(days: 1));
      }
    }
    Duration difference = wakeFullDateTime.difference(bedFullDateTime);
    if (difference.isNegative) return null;
    if (difference.inHours > 24) return null;
    return difference.inMinutes / 60.0;
  }

  Future<void> _saveSleepLog() async {
    print("LogNightlySleepScreen: _saveSleepLog CALLED.");
    if (!mounted) return;

    final currentContext = context;
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
      );
      return;
    }
    final double? durationHours = _calculateSleepDuration();

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    } else {
      return;
    }

    DateTime finalWakeTimestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );
    DateTime finalBedTimestamp =
        finalWakeTimestamp.subtract(Duration(minutes: (durationHours! * 60).round()));
    final String docId = "${user.uid}_${DateFormat('yyyy-MM-dd').format(_selectedDate)}";
    final DocumentReference sleepLogRef = _firestore.collection('user_nightly_sleep').doc(docId);

    try {
      await sleepLogRef.set({
        'userId': user.uid,
        'sleepStartTimestamp': Timestamp.fromDate(finalBedTimestamp),
        'sleepEndTimestamp': Timestamp.fromDate(finalWakeTimestamp),
        'sleepDurationHours': durationHours,
        'dateOfWakeUp': Timestamp.fromDate(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)),
        'loggedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Sleep logged: ${durationHours.toStringAsFixed(1)} hours'),
            backgroundColor: Colors.green),
      );
      if (mounted) {
        setState(() {
          _saveOperationCompletedSuccessfully = true;
        });
      }
    } on TimeoutException catch (e) {
      print("LogNightlySleepScreen: TimeoutException: $e");
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Save failed: Timeout. Check connection.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("LogNightlySleepScreen: Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Error saving sleep: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Renamed from _resetAndNavigate to _resetToSelectionScreen
  void _resetToSelectionScreen() {
    print("_resetToSelectionScreen called // Check for sound session");
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SleepActivityScreen()),
    );

    // Optional: Reset state if you wanted to stay on this screen and log another
    // if (mounted) {
    //   setState(() {
    //     _bedTime = null;
    //     _wakeTime = null;
    //     // _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    //     _isSaving = false;
    //     _saveOperationCompletedSuccessfully = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final double? calculatedDuration = _calculateSleepDuration();
    final Color startAnotherTextColor = _saveOperationCompletedSuccessfully
                                      ? Colors.tealAccent.shade200
                                      : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _saveOperationCompletedSuccessfully ? 'Log Saved' : 'Log Nightly Sleep',
            style: GoogleFonts.lato(color: Colors.white)
        ),
        backgroundColor: const Color(0xFF2D2D5A).withOpacity(0.85),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !_saveOperationCompletedSuccessfully,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sleep_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!_saveOperationCompletedSuccessfully) ...[
                  Text(
                    'For the night ending on the morning of:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: 17, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                    label: Text(
                      DateFormat('EEEE, MMM d, y').format(_selectedDate),
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: _isSaving ? null : () => _pickDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTimePickerRow(
                    context: context,
                    label: 'Went to Bed:',
                    time: _formatTimeOfDay(_bedTime),
                    onPressed: _isSaving ? null : () => _pickTime(context, true),
                  ),
                  const SizedBox(height: 20),
                  _buildTimePickerRow(
                    context: context,
                    label: 'Woke Up:',
                    time: _formatTimeOfDay(_wakeTime),
                    onPressed: _isSaving ? null : () => _pickTime(context, false),
                  ),
                  const SizedBox(height: 35),
                ],
                if (_saveOperationCompletedSuccessfully)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Sleep log successfully saved!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                  ),

                if (calculatedDuration != null && calculatedDuration > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'Total Sleep: ${calculatedDuration.toStringAsFixed(1)} hours',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.tealAccent.shade100),
                    ),
                  ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: (_isSaving || _saveOperationCompletedSuccessfully || !_canSaveChanges)
                      ? null
                      : _saveSleepLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledBackgroundColor: const Color(0xFF4DB6AC).withOpacity(0.5),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Sleep Log', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 15),

                TextButton(
                  onPressed: _saveOperationCompletedSuccessfully
                             ? _resetToSelectionScreen // <<< CONFIRMED CHANGE
                             : null,
                  child: Text(
                     "Go to Activities",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: startAnotherTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTimePickerRow({
    required BuildContext context,
    required String label,
    required String time,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: (_isSaving || _saveOperationCompletedSuccessfully) ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.lato(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Text(
                    time,
                    style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.tealAccent.shade200),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, color: Colors.tealAccent.shade100.withOpacity(0.7), size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// REMEMBER TO CREATE/HAVE SleepActivityScreen.dart
// Example:
/*
// lib/screens/activities/SleepActivityScreen.dart
import 'package:flutter/material.dart';

class SleepActivityScreen extends StatelessWidget {
  const SleepActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Activities'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Welcome to Sleep Activities!'),
      ),
    );
  }
}
*/