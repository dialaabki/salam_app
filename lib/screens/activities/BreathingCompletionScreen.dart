// File: lib/screens/activities/BreathingCompletionScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed
// Import the intro screen to navigate back to it
import 'BreathingIntroScreen.dart'; // Path confirmed by user

class BreathingCompletionScreen extends StatefulWidget {
  const BreathingCompletionScreen({super.key});

  @override
  State<BreathingCompletionScreen> createState() => _BreathingCompletionScreenState();
}

class _BreathingCompletionScreenState extends State<BreathingCompletionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSavingCompletion = false;
  final int _activityDurationMinutes = 1; // Fixed duration for breathing activity

  Future<void> _saveCompletionToFirestore() async {
    if (!mounted) {
      print("BreathingCompletion: Aborting, widget not mounted at start.");
      return;
    }

    print("BreathingCompletion: START. Setting _isSavingCompletion = true.");
    setState(() { _isSavingCompletion = true; });

    try {
      final user = _auth.currentUser;
      String? snackBarMessage;
      Color? snackBarColor;

      if (user == null) {
        print("BreathingCompletion: User not logged in.");
        snackBarMessage = "Error: Not logged in. Activity not saved.";
        snackBarColor = Colors.red;
      } else {
        print("BreathingCompletion: Attempting to log to Firestore. User ID: ${user.uid}, Duration: $_activityDurationMinutes");
        final String activityName = 'Breathing';
        final int durationToLog = _activityDurationMinutes;
        final now = DateTime.now();
        final String dateString = DateFormat('yyyy-MM-dd').format(now);
        final String documentId = "${user.uid}_$dateString";
        final DocumentReference dailySummaryRef = _firestore.collection('daily_activity_summary').doc(documentId);
        
        final activityData = {
          'userId': user.uid,
          'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
          'durations': { activityName: FieldValue.increment(durationToLog.toDouble()) },
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        };
        
        await dailySummaryRef.set(activityData, SetOptions(merge: true));
        
        print("BreathingCompletion: Firestore log SUCCESS!");
        snackBarMessage = "Breathing activity logged!";
        snackBarColor = Colors.green;
      }

      if (mounted && snackBarMessage != null) {
        print("BreathingCompletion: Attempting to show SnackBar: '$snackBarMessage'");
        // Use a local ScaffoldMessengerState if context might change rapidly,
        // or ensure delay allows current context to be used.
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text(snackBarMessage), backgroundColor: snackBarColor),
        );
        await Future.delayed(const Duration(milliseconds: 1500)); 
        print("BreathingCompletion: SnackBar delay finished.");
      } else if (snackBarMessage != null) {
         print("BreathingCompletion: SnackBar message present but widget not mounted before display attempt.");
      }

    } catch (e, s) {
      print("BreathingCompletion: EXCEPTION in try block: $e");
      print("BreathingCompletion: StackTrace: $s");
      if (mounted) {
        String shortError = e.toString();
        if (shortError.length > 100) shortError = "${shortError.substring(0, 97)}...";
        // Use a local ScaffoldMessengerState
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text("Error saving: $shortError"), backgroundColor: Colors.red),
        );
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } finally {
      print("BreathingCompletion: FINALLY block. mounted: $mounted");
      if (mounted) {
        print("BreathingCompletion: FINALLY - Navigating back to BreathingIntroScreen.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BreathingIntroScreen()),
          // This predicate removes routes until the first one in the stack is reached,
          // then pushes BreathingIntroScreen. This effectively restarts the breathing flow.
          (Route<dynamic> route) => route.isFirst, 
        );
      } else {
        print("BreathingCompletion: FINALLY - Widget not mounted, cannot navigate or reset state.");
      }
    }
    print("BreathingCompletion: _saveCompletionToFirestore END.");
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF1E4B5F);
    const Color finishButtonColor = Color(0xFF3E8A9A);
    const Color backButtonColor = primaryTextColor;

    return Scaffold(
      // These two properties allow the body to draw behind system UI
      extendBody: true, 
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          // Background Image fills the entire extended body
          Positioned.fill(
            child: Image.asset(
              'assets/images/breathing_bg.png', 
               fit: BoxFit.cover, 
            ),
          ),

          // SafeArea ensures content is not obscured by system UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0, 
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Breathe in peace,\nbreathe out stress.\nYou\'re doing amazing!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/lungs_complete.png', 
                    height: MediaQuery.of(context).size.height * 0.25,
                    errorBuilder: (c, e, s) => const Center(child: Text('Error loading image')),
                  ),
                  const Spacer(flex: 3),
                  ElevatedButton(
                    onPressed: _isSavingCompletion ? null : _saveCompletionToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: finishButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledBackgroundColor: finishButtonColor.withOpacity(0.5),
                    ),
                    child: _isSavingCompletion
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Finish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),

          // Back button positioned considering the status bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 5, // 5px below status bar
            left: 10,
            child: IconButton(
              icon: Icon( Icons.arrow_back_ios_new, color: backButtonColor),
              tooltip: 'Back',
              onPressed: _isSavingCompletion ? null : () {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const BreathingIntroScreen()),
                    (Route<dynamic> route) => route.isFirst, 
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}