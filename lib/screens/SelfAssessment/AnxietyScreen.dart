// anxietyscreen.dart
import 'package:flutter/material.dart';
// import 'dart:convert'; // Keep for potential future use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import keys from SelfAssessmentScreen
// Adjust the import path if necessary
import 'SelfAssessmentScreen.dart'
    show keyAnxiety, firestoreCollection, fieldPartialSaves;

class AnxietyScreen extends StatefulWidget {
    final Map<String, dynamic>? initialState;// Accepts initial state

  const AnxietyScreen({super.key, this.initialState});

  @override
  State<AnxietyScreen> createState() => _AnxietyScreenState();
}

class _AnxietyScreenState extends State<AnxietyScreen> {
  // --- UI Styling Constants ---
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _introTextColor = const Color(0xFF276181);
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // --- State Variables for Answers ---
  // Initialize with defaults (8 questions in GAD-7 + impairment)
  List<int?> _answers = List.filled(8, null);

  // --- Firebase Instances and User Info ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false; // To show loading indicator on save button

  // --- Questions Data ---
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Q1. Feeling nervous, anxious, or on edge?',
      'options': [
        'Not at all', // Score 0
        'Several days', // Score 1
        'More than half the days', // Score 2
        'Nearly every day', // Score 3
      ],
    },
    {
      'question': 'Q2. Not being able to stop or control worrying?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question': 'Q3. Worrying too much about different things?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question': 'Q4. Trouble relaxing?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question': 'Q5. Being so restless that it is hard to sit still?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question': 'Q6. Easily annoyed or irritable?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question': 'Q7. Feeling afraid, something awful will happen.',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
      ],
    },
    {
      'question':
          'Q8. If you checked any problems, how difficult have they made it for you to do your work, take care of things at home, or get along with other people?',
      'options': [
        // This question is for impairment, not typically scored in GAD-7 sum
        'Not difficult at all',
        'Somewhat difficult',
        'Very difficult',
        'Extremely difficult',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _userProgressDocRef = _firestore
          .collection(firestoreCollection)
          .doc(_currentUser!.uid);
      print("[AnxietyScreen] initState: User ID: ${_currentUser!.uid}");
      print(
        "[AnxietyScreen] Progress Document Path: ${_userProgressDocRef?.path}",
      );
      _initializeState(); // Initialize state using passed data
    } else {
      print("Error: CurrentUser is null in AnxietyScreen initState.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: User not logged in."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop(); // Go back
        }
      });
    }
  }

  // Initialize state from passed data (if any)
  void _initializeState() {
    if (widget.initialState != null && mounted) {
      print(
        "AnxietyScreen: Initializing state from passed data: ${widget.initialState}",
      );
      try {
        if (widget.initialState!.containsKey('answers') &&
            widget.initialState!['answers'] is List) {
          List<dynamic> dynamicList = widget.initialState!['answers'];
          List<int?> loadedAnswers =
              dynamicList.map((item) => item is int ? item : null).toList();

          if (loadedAnswers.length == _answers.length) {
            setState(() {
              _answers = loadedAnswers;
            });
            print("AnxietyScreen: Initialized with saved state: $_answers");
          } else {
            print(
              "AnxietyScreen: Initial state 'answers' length mismatch (${loadedAnswers.length} vs ${_answers.length}). Using defaults.",
            );
          }
        } else {
          print(
            "AnxietyScreen: Initial state missing 'answers' key or not a list. Using defaults.",
          );
        }
      } catch (e) {
        print(
          "AnxietyScreen: Error parsing initial state data: $e. Using defaults.",
        );
        setState(() {
          _answers = List.filled(8, null); // Reset to default
        });
      }
    } else {
      print("AnxietyScreen: No initial state passed. Using defaults.");
    }
  }

  // Save CURRENT state to Firestore partial saves
  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print(
        "AnxietyScreen Error: Cannot save state, _userProgressDocRef is null.",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save. Are you logged in?'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (!mounted) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> currentStateForFirestore = {'answers': _answers};
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyAnxiety';

    print("AnxietyScreen: Attempting to save partial state to Firestore.");
    print("AnxietyScreen: Document Path: ${_userProgressDocRef?.path}");
    print(
      "AnxietyScreen: Data to save under '$keyAnxiety': $currentStateForFirestore",
    );

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyAnxiety: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPathForThisStep]));

      print("AnxietyScreen: Partial state SAVE SUCCEEDED for '$keyAnxiety'.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, 'saved'); // Signal save occurred
      }
    } catch (e, s) {
      print("AnxietyScreen: Error saving state to Firestore: $e");
      print("AnxietyScreen: Stack trace: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save progress.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Clear THIS STEP'S partial save data from Firestore upon completion
  Future<void> _clearPartialSaveFromFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;

    final String fieldPathForThisStep = '$fieldPartialSaves.$keyAnxiety';
    print(
      "AnxietyScreen: Attempting to clear partial save for '$keyAnxiety' at ${_userProgressDocRef!.path}",
    );
    try {
      await _userProgressDocRef!.update({
        fieldPathForThisStep: FieldValue.delete(),
      });
      print(
        "AnxietyScreen: Cleared partial save for '$keyAnxiety' from Firestore.",
      );
    } catch (e, s) {
      print(
        "AnxietyScreen: Error clearing partial save for '$keyAnxiety' from Firestore: $e.",
      );
      print("Stack trace: $s");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: _primaryColor,
        ),
        body: const Center(
          child: Text("User not available. Please log in again."),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        print("AnxietyScreen: Back button pressed.");
        Navigator.pop(context, null); // Signal normal back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anxiety Assessment (Step 2)'),
          backgroundColor: _primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null), // Normal back signal
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(),
              const SizedBox(height: 16.0),
              _buildIntroText(),
              const SizedBox(height: 24.0),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionBlock(index);
                },
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: _dividerColor, thickness: 1.0),
                  );
                },
              ),
              const SizedBox(height: 30.0),
              _buildNavigateButton(), // "Complete Step" button
              const SizedBox(height: 12.0),
              _buildSaveLink(), // "Save and continue later" link
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    const String imagePath =
        'assets/images/step2pic.png'; // Ensure path is correct
    return Center(
      child: Image.asset(
        imagePath,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image '$imagePath': $error");
          return Container(
            height: 60,
            width: 100,
            color: _inactiveColor.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Over the last two weeks, how often have you been bothered by the following problems?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: _introTextColor,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildQuestionBlock(int questionIndex) {
    bool isLastQuestion = questionIndex == _questions.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questions[questionIndex]['question'],
          style: TextStyle(
            fontSize:
                isLastQuestion
                    ? 16.0
                    : 17.0, // Slightly smaller for last q if needed
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children: List.generate(
            _questions[questionIndex]['options'].length,
            (optionIndex) => _buildOption(
              text: _questions[questionIndex]['options'][optionIndex],
              optionValue: optionIndex, // Value is 0, 1, 2, 3
              questionIndex: questionIndex,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String text,
    required int optionValue,
    required int questionIndex,
  }) {
    final bool isSelected = _answers[questionIndex] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _answers[questionIndex] = optionValue;
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.0,
              height: 22.0,
              margin: const EdgeInsets.only(top: 2.0, right: 12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _borderColor : _inactiveColor,
                  width: 2.0,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _borderColor,
                          ),
                        ),
                      )
                      : null,
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 15.0, color: _optionTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the "Complete Step" button
  Widget _buildNavigateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Make async
          if (!mounted) return;
          // Validate: Check if all questions are answered
          bool allAnswered = !_answers.contains(null);
          if (!allAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please answer all questions before proceeding.'),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // Clear partial save for this step from Firestore
          await _clearPartialSaveFromFirestore();

          // Pop back with the final answers
          print('Step 2 (Anxiety) Answers: $_answers');
          Navigator.pop(context, List<int?>.from(_answers)); // Return a copy
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
        child: const Text('Complete Step 2'),
      ),
    );
  }

  // Builds the "Save and continue later" link
  Widget _buildSaveLink() {
    return Center(
      child: InkWell(
        onTap:
            _isSaving
                ? null
                : _saveStateToFirestore, // Disable tap while saving
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Larger tap area
          child:
              _isSaving
                  ? SizedBox(
                    // Show progress indicator
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: _primaryColor,
                    ),
                  )
                  : Text(
                    // Show text link
                    'Save and continue later >>',
                    style: TextStyle(
                      fontSize: 14,
                      color: _primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: _primaryColor,
                    ),
                  ),
        ),
      ),
    );
  }
}