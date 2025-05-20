// File: lib/screens/activities/WalkingActivityScreen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// --- Firebase Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed
// Import main for route constants if needed for navigation elsewhere
// import '../../main.dart';


class WalkingActivityScreen extends StatefulWidget {
  const WalkingActivityScreen({Key? key}) : super(key: key);

  @override
  State<WalkingActivityScreen> createState() => _WalkingActivityScreenState();
}

class _WalkingActivityScreenState extends State<WalkingActivityScreen> {
  int _selectedDuration = 30; // Default duration in minutes
  int _remainingSeconds = 0; // Timer countdown seconds
  Timer? _timer; // Timer for the activity countdown
  Timer? _navTimer; // Timer specifically for nav bar (if needed by AppBottomNavBar)
  int _screenState = 0; // 0: Duration Selection, 1: Timer Running, 2: Completion

  // --- ADDED: Track start time and actual duration ---
  DateTime? _timerStartTime; // When the timer actually started
  int? _actualDurationCompletedMinutes; // Stores the duration if finished early

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Saving State ---
  bool _isSavingCompletion = false; // To show loading/disable button while saving

  @override
  void dispose() {
    _timer?.cancel(); // Cancel activity timer
    _navTimer?.cancel(); // Cancel nav timer if used
    super.dispose();
  }

  // --- Timer Logic ---
  void _startTimer() {
    if (!mounted) return;
    _timerStartTime = DateTime.now(); // <<< Record start time
    setState(() {
      _remainingSeconds = _selectedDuration * 60; // Convert selected minutes to seconds
      _screenState = 1; // Move to Timer Running screen state
      _actualDurationCompletedMinutes = null; // Reset actual duration when starting
    });

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { // Check if widget is still mounted before updating state
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--; // Decrement countdown
        } else {
          _timer?.cancel(); // Stop timer when reaches zero
          // Timer completed normally, actual duration is the selected duration
          _actualDurationCompletedMinutes = _selectedDuration; // Store the full duration
          _screenState = 2; // Move to Completion screen state
          _remainingSeconds = 0; // Ensure it stays at 0
        }
      });
    });
  }

  // --- Time Formatting ---
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60; // Integer division for minutes
    int remainingSeconds = seconds % 60; // Remainder for seconds
    // Pad with leading zeros if needed
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // --- Main Body Builder ---
  Widget _buildBody() {
    switch (_screenState) {
      case 1:
        return _buildTimerScreen(); // Show timer UI
      case 2:
        return _buildCompletionScreen(); // Show completion UI
      case 0:
      default:
        return _buildDurationSelectionScreen(); // Show initial selection UI
    }
  }

  // --- AppBar Icon Color Logic ---
  Color _getAppBarIconColor() {
     final theme = Theme.of(context);
    switch (_screenState) {
      case 1: case 2:
        return theme.colorScheme.primary;
      case 0: default:
        return Colors.white;
    }
  }

  // --- Back Button Logic ---
  void _handleBackButton() {
    if (!mounted) return;
    _timer?.cancel(); // Always cancel activity timer when going back

    setState(() {
      if (_screenState == 1 || _screenState == 2) {
        // If on Timer or Completion, go back to Duration Selection
        _screenState = 0;
        _remainingSeconds = 0; // Reset timer display value
        _actualDurationCompletedMinutes = null; // <<< Reset actual duration
        _isSavingCompletion = false; // Reset saving state if going back from completion
      } else {
        // If already on Duration Selection, pop the screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  // --- NEW Function to handle finishing early ---
  void _finishEarly() {
    if (_timer == null || !_timer!.isActive || _timerStartTime == null || !mounted) {
      // Timer not running or start time not recorded
      return;
    }

    _timer?.cancel(); // Stop the timer

    // Calculate elapsed duration
    final Duration elapsedDuration = DateTime.now().difference(_timerStartTime!);
    // Calculate minutes, rounding up partial minutes (e.g., 1 sec = 1 min logged)
    final int elapsedMinutes = (elapsedDuration.inSeconds / 60).ceil();

    print("Activity finished early after ${elapsedDuration.inSeconds} seconds ($elapsedMinutes minutes).");

    setState(() {
      _actualDurationCompletedMinutes = elapsedMinutes < 1 ? 1 : elapsedMinutes; // Log at least 1 minute
      _screenState = 2; // Move to completion screen
      _remainingSeconds = 0; // Set remaining to 0 as it's finished
    });
  }
  // --- END NEW Function ---

   // --- Firestore Saving Logic (Accepts Duration) ---
  Future<void> _saveCompletionToFirestore({required int durationToLog}) async { // <<< Added parameter
      if (!mounted) return;
      setState(() { _isSavingCompletion = true; });

      final user = _auth.currentUser;
      if (user == null) {
        print("WalkingActivity: Cannot save completion, user not logged in.");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Not logged in."), backgroundColor: Colors.red,));
        if(mounted) setState(() { _isSavingCompletion = false; });
        return;
      }
      print("SAVE_ACTIVITY_SUMMARY: User ID: ${user.uid}, Logging Duration: $durationToLog");

      final String activityName = 'Walking';
      // final int durationMinutes = _selectedDuration; // <<< REMOVED: Use parameter instead

      // --- Generate Daily Document ID ---
      final now = DateTime.now();
      final String dateString = DateFormat('yyyy-MM-dd').format(now);
      final String documentId = "${user.uid}_$dateString";
      final DocumentReference dailySummaryRef = _firestore
          .collection('daily_activity_summary') // Use new collection name
          .doc(documentId);

      // Use the durationToLog parameter here
      final activityData = {
        'userId': user.uid,
        'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
        'durations': {
          activityName: FieldValue.increment(durationToLog.toDouble()) // <<< Use durationToLog
        },
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      print("SAVE_ACTIVITY_SUMMARY: Data to merge: $activityData");

      try {
        await dailySummaryRef.set(activityData, SetOptions(merge: true));
        print("SAVE_ACTIVITY_SUMMARY: Success! Daily summary updated for $activityName ($durationToLog mins).");

        if (mounted) {
          setState(() {
            _screenState = 0; // Go back to selection screen
            _remainingSeconds = 0;
            _actualDurationCompletedMinutes = null; // Reset actual duration
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Activity logged successfully!"), backgroundColor: Colors.green,));
        }

      } catch (e) {
         print("Error saving/updating daily activity summary: $e");
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to log activity: ${e.toString()}"), backgroundColor: Colors.red,));
         }
      } finally {
         // Ensure loading indicator stops
         if (mounted) {
           setState(() { _isSavingCompletion = false; });
         }
      }
  }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context); // Access theme data

    return Scaffold(
      extendBodyBehindAppBar: _screenState == 0, // Extend body only for selection screen
      appBar: AppBar(
        // Adjust background based on state for visibility
        backgroundColor: _screenState == 0 ? Colors.transparent : theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _getAppBarIconColor()),
          tooltip: 'Back',
          onPressed: _isSavingCompletion ? null : _handleBackButton, // Disable back while saving
        ),
      ),
      body: _buildBody(), // Dynamically builds content based on state
      bottomNavigationBar: AppBottomNavBar( // Use your shared nav bar
        navigationTimer: _navTimer, // Pass timer if needed
      ),
    );
  }

  // --- UI Builder: Duration Selection (_screenState == 0) ---
  Widget _buildDurationSelectionScreen() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/walking_background.png'), // Ensure path is correct
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text( 'Walking Activity', style: GoogleFonts.cormorant( fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF5588A4)),),
              const SizedBox(height: 10),
              const Text( 'Every step you take is progress!', style: TextStyle(fontSize: 16, color: Color(0xFF5588A4))),
              const SizedBox(height: 40),
              const Text( 'Select Walk Duration', style: TextStyle(fontSize: 20, color: Color(0xFF5588A4), fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton( icon: const Icon( Icons.remove_circle_outline, color: Color(0xFF5588A4), size: 35,), onPressed: () { if (!mounted) return; setState(() { if (_selectedDuration > 5) _selectedDuration -= 5; }); },),
                  Container( width: 100, alignment: Alignment.center, child: Text( '$_selectedDuration min', style: const TextStyle( fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF5588A4)),),),
                  IconButton( icon: const Icon( Icons.add_circle_outline, color: Color(0xFF5588A4), size: 35,), onPressed: () { if (!mounted) return; setState(() { if (_selectedDuration < 120) _selectedDuration += 5; }); },),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF5588A4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                child: const Text('Start Walk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Builder: Timer Running (_screenState == 1) ---
  Widget _buildTimerScreen() {
     final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( _formatTime(_remainingSeconds), style: TextStyle( fontSize: 54, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),),
                const SizedBox(height: 40),
                Text( 'REMINDER!', style: TextStyle( fontSize: 20, color: theme.colorScheme.secondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text( 'Every step you take is a step toward\na healthier, happier you.', textAlign: TextAlign.center, style: GoogleFonts.cormorant( fontSize: 18, color: theme.textTheme.bodyMedium?.color),),
                const SizedBox(height: 30),
                Expanded( child: Padding( padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Image.asset( 'assets/images/W_activity_image.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Center(child: Text('Error loading image', style: TextStyle(color: Colors.red))),),),),
                const SizedBox(height: 20),

                 // --- Row for Cancel/Finish buttons ---
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                      // Cancel Button
                      TextButton(
                        onPressed: _handleBackButton,
                        child: const Text("Cancel Activity", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                      ),
                      // Finish Early Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text("Finish Early"),
                        onPressed: _finishEarly, // Calls the new finish function
                        style: ElevatedButton.styleFrom(
                           foregroundColor: Colors.white,
                           backgroundColor: Colors.green.shade600, // Use a distinct color
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8)
                        ),
                      )
                   ],
                 ),
                 // --- END Row ---
                 const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Builder: Completion Screen (_screenState == 2) ---
  Widget _buildCompletionScreen() {
    final theme = Theme.of(context);
    // Determine which duration to display and save
    // Use _actualDurationCompletedMinutes if it exists (finished early), otherwise use _selectedDuration
    final int durationCompleted = _actualDurationCompletedMinutes ?? _selectedDuration;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( 'Well done!', style: TextStyle( fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),),
                const SizedBox(height: 10),
                // Display the ACTUAL completed duration
                Text(
                  'You completed $durationCompleted minute${durationCompleted == 1 ? '' : 's'} of walking!\nStay hydrated!', // Correct pluralization
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 20),
                Expanded(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Image.asset(
                      'assets/images/WW_activity_image.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Text('Error loading image', style: TextStyle(color: Colors.red))),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  // Call save function, passing the correct duration
                  onPressed: _isSavingCompletion
                      ? null
                      : () => _saveCompletionToFirestore(durationToLog: durationCompleted), // Pass correct duration
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                     textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isSavingCompletion
                      ? SizedBox( height: 20, width: 20, child: CircularProgressIndicator( color: theme.colorScheme.onPrimary, strokeWidth: 2.5,))
                      : const Text('Finish'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

} // End of _WalkingActivityScreenState