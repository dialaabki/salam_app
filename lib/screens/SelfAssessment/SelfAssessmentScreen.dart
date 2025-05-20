// self_assessment_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
// Firebase Imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import assessment screens (ensure correct paths and filenames)
// Make sure filenames match exactly, including case sensitivity if needed
import 'DepressionScreen.dart';
import 'Anxietyscreen.dart'; // Ensure this filename is correct (e.g., AnxietyScreen.dart)
import 'OCDScreen.dart';
import 'BipolarScreen.dart';
import 'ADHDScreen.dart';
import 'AddictionScreen.dart';
import 'FinalResultsScreen.dart';
import '/main.dart'; // Example: If main.dart is one level up

// --- Keys (Field names in Firestore and map keys) ---
const String firestoreCollection = 'assessment_progress'; 
const String fieldHighestCompleted = 'highestCompletedStepIndex';
const String fieldPartialSaves = 'partialSaves';
const String keyDepression = 'depression';
const String keyAnxiety = 'anxiety';
const String keyOCD = 'ocd';
const String keyBipolar = 'bipolar';
const String keyADHD = 'adhd';
const String keyAddiction = 'addiction';
// --- End Keys ---

class SelfAssessmentScreen extends StatefulWidget {
  const SelfAssessmentScreen({super.key});

  @override
  State<SelfAssessmentScreen> createState() => _SelfAssessmentScreenState();
}

class _SelfAssessmentScreenState extends State<SelfAssessmentScreen> {
  // Define Colors
  final Color headerColor = const Color(0xFF5588A4);
  final Color contentBgColor = Colors.white;
  final Color primaryTextColor = const Color(0xFF276181);
  final Color secondaryTextColor = Colors.black54;
  final Color stepItemBgColor = const Color(0xFFF8F8F8);
  final Color stepTextColor = Colors.grey;
  final Color stepTitleColor = Colors.black87;
  final Color checkmarkColorFilled = Colors.green;
  final Color checkmarkColorEmpty = Colors.grey.shade400;
  final Color skipLinkColor = const Color(0xFF5588A4);
  final Color inProgressColor = Colors.orange;

  // --- State Variables ---
  int _highestCompletedStepIndex = -1;
  // Stores COMPLETED results in memory only until final submission
  final Map<String, dynamic> _allAssessmentResults = {};

  // --- Firebase Related State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isLoading = true;
  Map<String, dynamic> _partialSavesData = {}; // Stores raw partial save data

  // --- Data for the Steps ---
  // Defined as final, initialized directly
  late final List<Map<String, dynamic>> _assessmentSteps;

  @override
  void initState() {
    super.initState();
    _assessmentSteps = [
      {
        'key': keyDepression,
        'step': 'Step-1',
        'title': 'Depression',
        'screenBuilder': (data) => DepressionScreen(initialState: data),
      },
      {
        'key': keyAnxiety,
        'step': 'Step-2',
        'title': 'Anxiety',
        'screenBuilder': (data) => AnxietyScreen(initialState: data),
      },
      {
        'key': keyOCD,
        'step': 'Step-3',
        'title': 'OCD',
        'screenBuilder': (data) => OCDScreen(initialState: data),
      },
      {
        'key': keyBipolar,
        'step': 'Step-4',
        'title': 'Bipolar Disorder',
        'screenBuilder': (data) => BipolarScreen(initialState: data),
      },
      {
        'key': keyADHD,
        'step': 'Step-5',
        'title': 'ADHD',
        'screenBuilder': (data) => ADHDScreen(initialState: data),
      },
      {
        'key': keyAddiction,
        'step': 'Step-6',
        'title': 'Addiction',
        'screenBuilder': (data) => AddictionScreen(initialState: data),
      },
    ];

    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      print(
        "Error: User is null in SelfAssessmentScreen initState. Redirecting to login.",
      );
      // Schedule navigation after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use Navigator.pushNamedAndRemoveUntil to clear stack if needed
          Navigator.pushReplacementNamed(context, MyApp.loginRoute);
        }
      });
      // Set loading to false so it doesn't hang on loading indicator
      setState(() {
        _isLoading = false;
      });
    } else {
      _userProgressDocRef = _firestore
          .collection(firestoreCollection)
          .doc(_currentUser!.uid);
      print("[SelfAssessmentScreen] initState: User ID: ${_currentUser!.uid}");
      print(
        "[SelfAssessmentScreen] Progress Document Path: ${_userProgressDocRef?.path}",
      );
      _loadProgressFromFirestore();
    }
  }

  Future<void> _loadProgressFromFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    print(
      "[SelfAssessmentScreen] Loading progress from Firestore: ${_userProgressDocRef!.path}",
    );
    try {
      final docSnapshot = await _userProgressDocRef!.get();

      if (docSnapshot.exists && mounted) {
        final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
        print("[SelfAssessmentScreen] Firestore Data Loaded: $data");
        setState(() {
          _highestCompletedStepIndex =
              data[fieldHighestCompleted] as int? ?? -1;
          // Ensure partialSaves is treated as a Map<String, dynamic>
          _partialSavesData =
              (data[fieldPartialSaves] is Map<String, dynamic>)
                  ? Map<String, dynamic>.from(data[fieldPartialSaves])
                  : {};
          print(
            "Firestore Load: HighestCompleted=$_highestCompletedStepIndex, PartialSavesKeys=${_partialSavesData.keys}",
          );
        });
      } else {
        print(
          "Firestore Load: No document found for user ${_currentUser!.uid} at ${_userProgressDocRef!.path}. Initializing state.",
        );
        // Ensure state is reset if no document exists
        if (mounted) {
          setState(() {
            _highestCompletedStepIndex = -1;
            _partialSavesData = {};
          });
        }
      }
    } catch (e, s) {
      print("Error loading progress from Firestore: $e");
      print("Stack trace: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading progress.'),
            backgroundColor: Colors.red,
          ),
        );
        // Reset state on error
        setState(() {
          _highestCompletedStepIndex = -1;
          _partialSavesData = {};
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateHighestCompletedInFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    try {
      print(
        "[SelfAssessmentScreen] Updating highestCompletedStepIndex to $_highestCompletedStepIndex in Firestore: ${_userProgressDocRef!.path}",
      );
      await _userProgressDocRef!.set({
        fieldHighestCompleted: _highestCompletedStepIndex,
      }, SetOptions(merge: true));
      print(
        "Firestore Update: Set highestCompletedStepIndex to $_highestCompletedStepIndex",
      );
    } catch (e, s) {
      print("Error updating highest completed index in Firestore: $e");
      print("Stack trace: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving progress step.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllSavedStateInFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    print(
      '[SelfAssessmentScreen] Clearing all assessment state in Firestore for user ${_currentUser?.uid} at ${_userProgressDocRef!.path}...',
    );
    try {
      await _userProgressDocRef!.delete();
      if (mounted) {
        // Reset local state as well
        setState(() {
          _highestCompletedStepIndex = -1;
          _partialSavesData = {};
          _allAssessmentResults.clear(); // Clear in-memory results too
        });
      }
      print('[SelfAssessmentScreen] Firestore document deleted successfully.');
    } catch (e, s) {
      print("Error clearing Firestore state: $e");
      print("Stack trace: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error clearing saved progress.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToStep(BuildContext context, int stepIndex) async {
    if (!mounted || _currentUser == null) return;

    final stepData = _assessmentSteps[stepIndex];
    final String stepKey = stepData['key'];
    final Function(dynamic) screenBuilder = stepData['screenBuilder'];

    bool isPartiallySaved = _partialSavesData.containsKey(stepKey);
    bool isStepActuallyCompleted = stepIndex <= _highestCompletedStepIndex;

    bool isAllowed =
        isStepActuallyCompleted ||
        isPartiallySaved ||
        stepIndex == _highestCompletedStepIndex + 1;

    if (!isAllowed) {
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} access denied. Highest: $_highestCompletedStepIndex, Partial: $isPartiallySaved, Completed: $isStepActuallyCompleted",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _highestCompletedStepIndex < _assessmentSteps.length - 1
                  ? 'Please complete Step ${_highestCompletedStepIndex + 2} first.'
                  : 'All steps completed.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    print(
      "[SelfAssessmentScreen] Navigating to Step ${stepIndex + 1} ('$stepKey'). Passing partial data: ${_partialSavesData[stepKey]}",
    );
    dynamic initialDataForScreen = _partialSavesData[stepKey];

    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (ctx) => screenBuilder(initialDataForScreen)),
    );

    if (!mounted) return;
    print(
      "[SelfAssessmentScreen] --- Returned from Step ${stepIndex + 1} ('$stepKey') --- Result: $result",
    );

    bool needsUiRefresh = false;

    if (result != null && result != false && result != 'saved') {
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} COMPLETED with data.",
      );
      _allAssessmentResults[stepKey] = result;

      if (_partialSavesData.containsKey(stepKey)) {
        _partialSavesData.remove(stepKey);
        needsUiRefresh = true;
      }

      if (stepIndex > _highestCompletedStepIndex) {
        _highestCompletedStepIndex = stepIndex;
        await _updateHighestCompletedInFirestore();
        needsUiRefresh = true;
      } else if (stepIndex == _highestCompletedStepIndex &&
          !isStepActuallyCompleted) {
        needsUiRefresh = true;
      }

      if (_highestCompletedStepIndex == _assessmentSteps.length - 1) {
        print(
          "[SelfAssessmentScreen] All steps complete! Navigating to results.",
        );
        final Map<String, dynamic> finalResultsToSend = Map.from(
          _allAssessmentResults,
        );
        await _clearAllSavedStateInFirestore();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FinalResultsScreen(allResults: finalResultsToSend),
            ),
          );
        }
        return;
      }
    } else if (result == 'saved') {
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} SAVED partially. Reloading progress from Firestore.",
      );
      await _loadProgressFromFirestore();
      return;
    } else {
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} exited without explicit save/complete. Reloading progress.",
      );
      await _loadProgressFromFirestore();
      return;
    }

    if (needsUiRefresh && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "[SelfAssessmentScreen] build: isLoading=$_isLoading, highestCompleted=$_highestCompletedStepIndex, partialKeys=${_partialSavesData.keys}",
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: headerColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: headerColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "User not authenticated.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, MyApp.loginRoute);
                  }
                },
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: headerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width,
            ),
            _buildContentArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenHeight, double screenWidth) {
    const double horizontalPadding = 25.0;
    const double bottomTextPadding = 20.0;
    const double spaceAboveText = 5.0;
    const double approxTextHeight = 30.0;
    final double leftImageBottom =
        bottomTextPadding + approxTextHeight + spaceAboveText;
    const double rightImageTopPadding = 10.0;
    const double rightImageRightPadding = 15.0;
    final double rightImageHeight = screenHeight * 0.22;

    return Container(
      color: headerColor,
      height: screenHeight * 0.28,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: leftImageBottom,
            left: horizontalPadding,
            height: screenHeight * 0.12,
            child: Image.asset(
              'assets/images/selfassepic2.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 50,
                  ),
            ),
          ),
          Positioned(
            top: rightImageTopPadding,
            right: rightImageRightPadding,
            height: rightImageHeight,
            child: Image.asset(
              'assets/images/selfassepic1.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 60,
                  ),
            ),
          ),
          Positioned(
            bottom: bottomTextPadding,
            left: horizontalPadding,
            child: Text(
              'Self Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0.0, -30.0, 0.0),
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 20.0,
        right: 20.0,
        bottom: 30.0,
      ),
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35.0),
          topRight: Radius.circular(35.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Take a Step Towards\nUnderstanding Your Mental Health',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 15.0),
          Text(
            'Your Mental Health Matters – Answer\nAll Questions for Accurate Insights',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 35.0),
          Column(
            children: List.generate(_assessmentSteps.length, (index) {
              final stepData = _assessmentSteps[index];
              return _buildStepItem(
                context: context,
                step: stepData['step']!,
                title: stepData['title']!,
                stepKey: stepData['key']!,
                index: index,
                onTap: () => _navigateToStep(context, index),
              );
            }),
          ),
          const SizedBox(height: 30.0),
          _buildSkipLink(context),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required String step,
    required String title,
    required String stepKey,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isCompleted = index <= _highestCompletedStepIndex;
    final bool isInProgress =
        _partialSavesData.containsKey(stepKey) && !isCompleted;
    final bool isEnabled =
        isCompleted || isInProgress || index == _highestCompletedStepIndex + 1;

    final Color currentStepTextColor =
        isEnabled ? stepTextColor : stepTextColor.withOpacity(0.5);
    final Color currentTitleColor =
        isEnabled ? stepTitleColor : stepTitleColor.withOpacity(0.5);

    IconData iconData;
    Color iconColor;
    if (isCompleted) {
      iconData = Icons.check_circle;
      iconColor = checkmarkColorFilled;
    } else if (isInProgress) {
      iconData = Icons.pending_outlined;
      iconColor = inProgressColor;
    } else {
      iconData = Icons.radio_button_unchecked;
      iconColor =
          isEnabled
              ? checkmarkColorEmpty
              : checkmarkColorEmpty.withOpacity(0.5);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(15.0),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 18.0,
            ),
            decoration: BoxDecoration(
              color: stepItemBgColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 15,
                    color: currentStepTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(iconData, color: iconColor, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the "Skip for now" link
  Widget _buildSkipLink(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(
          '[SelfAssessmentScreen] Skip for now tapped. Current progress in Firestore will be preserved.',
        );

        // OLD BEHAVIOR (deleted existing progress):
        // await _clearAllSavedStateInFirestore();

        // NEW BEHAVIOR:
        // By not calling _clearAllSavedStateInFirestore(), any existing
        // highestCompletedStepIndex and partialSaves (which were saved by
        // individual step screens) will remain in Firestore.
        // The "save answers" in this context means "do not delete the answers
        // that have already been saved to Firestore."

        if (mounted) {
          // Navigate to the user's home screen, replacing the assessment flow
          Navigator.pushReplacementNamed(context, MyApp.userHomeRoute);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Make tap area larger
        child: Text(
          'Skip for now >>',
          style: TextStyle(
            fontSize: 15,
            color: skipLinkColor,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline, // Indicate it's a link
            decorationColor: skipLinkColor,
          ),
        ),
      ),
    );
  }
}