// ADHDScreen.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // Keep for potential future use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the keys and constants
// Adjust the import path if necessary
import 'SelfAssessmentScreen.dart'
    show keyADHD, firestoreCollection, fieldPartialSaves;

class ADHDScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState; // Accepts initial state

  const ADHDScreen({super.key, this.initialState});

  @override
  State<ADHDScreen> createState() => _ADHDScreenState();
}

class _ADHDScreenState extends State<ADHDScreen> {
  // --- UI Styling Constants ---
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // --- State Variables ---
  // ASRS v1.1 has 18 questions (6 Part A, 12 Part B)
  List<int?> _answers = List.filled(18, null);

  // --- Firebase Instances and State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false;

  // --- Questions Data ---
  // (Keep your existing _questions list here - omitted for brevity)
  final List<Map<String, dynamic>> _questions = [
    // Part A - Inattention (Q1-6, but only specific ones might be shaded on paper form)
    {
      'id': 1, // Index 0
      'type':
          'multiple_choice_5', // 0=Never, 1=Rarely, 2=Sometimes, 3=Often, 4=Very Often
      'question':
          'Q1. How often do you have trouble wrapping up the final details of a project, once the challenging parts have been done?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 2, // Index 1
      'type': 'multiple_choice_5',
      'question':
          'Q2. How often do you have difficulty getting things in order when you have to do a task that requires organization?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 3, // Index 2
      'type': 'multiple_choice_5',
      'question':
          'Q3. How often do you have problems remembering appointments or obligations?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 4, // Index 3
      'type': 'multiple_choice_5',
      'question':
          'Q4. When you have a task that requires a lot of thought, how often do you avoid or delay getting started?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 5, // Index 4
      'type': 'multiple_choice_5',
      'question':
          'Q5. How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 6, // Index 5
      'type': 'multiple_choice_5',
      'question':
          'Q6. How often do you feel overly active and compelled to do things, like you were driven by a motor?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    // Part B - Hyperactivity/Impulsivity & further Inattention (Q7-18)
    {
      'id': 7, // Index 6
      'type': 'multiple_choice_5',
      'question':
          'Q7. How often do you make careless mistakes when you have to work on a boring or difficult project?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 8, // Index 7
      'type': 'multiple_choice_5',
      'question':
          'Q8. How often do you have difficulty keeping your attention when you are doing boring or repetitive work?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 9, // Index 8
      'type': 'multiple_choice_5',
      'question':
          'Q9. How often do you have difficulty concentrating on what people say to you, even when they are speaking to you directly?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 10, // Index 9
      'type': 'multiple_choice_5',
      'question':
          'Q10. How often do you misplace or have difficulty finding things at home or at work?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 11, // Index 10
      'type': 'multiple_choice_5',
      'question':
          'Q11. How often are you distracted by activity or noise around you?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 12, // Index 11
      'type': 'multiple_choice_5',
      'question':
          'Q12. How often do you leave your seat in meetings or other situations in which you are expected to remain seated?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 13, // Index 12
      'type': 'multiple_choice_5',
      'question': 'Q13. How often do you feel restless or fidgety?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 14, // Index 13
      'type': 'multiple_choice_5',
      'question':
          'Q14. How often do you have difficulty unwinding and relaxing when you have time to yourself?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 15, // Index 14
      'type': 'multiple_choice_5',
      'question':
          'Q15. How often do you find yourself talking too much when you are in social situations?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 16, // Index 15
      'type': 'multiple_choice_5',
      'question':
          'Q16. When you’re in a conversation, how often do you find yourself finishing the sentences of the people you are talking to, before they can finish them themselves?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 17, // Index 16
      'type': 'multiple_choice_5',
      'question':
          'Q17. How often do you have difficulty waiting your turn in situations when turn taking is required?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 18, // Index 17
      'type': 'multiple_choice_5',
      'question': 'Q18. How often do you interrupt others when they are busy?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
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
      _initializeState();
    } else {
      print("Error: CurrentUser is null in ADHDScreen initState");
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

  void _initializeState() {
    if (widget.initialState != null && mounted) {
      print(
        "ADHDScreen: Initializing state from passed data: ${widget.initialState}",
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
            print("ADHDScreen: Initialized with saved state.");
          } else {
            print(
              "ADHDScreen: Initial state 'answers' length mismatch (${loadedAnswers.length} vs ${_answers.length}). Using defaults.",
            );
          }
        } else {
          print(
            "ADHDScreen: Initial state missing 'answers' key or not a list. Using defaults.",
          );
        }
      } catch (e) {
        print(
          "ADHDScreen: Error parsing initial state data: $e. Using defaults.",
        );
        setState(() {
          _answers = List.filled(18, null); // Reset
        });
      }
    } else {
      print("ADHDScreen: No initial state passed. Using defaults.");
    }
  }

  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print(
        "ADHDScreen Error: Cannot save state, _userProgressDocRef is null.",
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
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyADHD';

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyADHD: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPathForThisStep]));

      print("ADHDScreen: Partial state saved to Firestore.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, 'saved'); // Signal save
      }
    } catch (e) {
      print("ADHDScreen: Error saving state to Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save progress.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _clearPartialSaveFromFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyADHD';
    try {
      await _userProgressDocRef!.update({
        fieldPathForThisStep: FieldValue.delete(),
      });
      print("ADHDScreen: Cleared partial save for '$keyADHD' from Firestore.");
    } catch (e) {
      print(
        "ADHDScreen: Error clearing partial save for '$keyADHD' from Firestore: $e.",
      );
    }
  }

  // Helper to get the correct index in the _answers list (0-based)
  int _getAnswerIndex(int questionId) {
    // Assuming question IDs are sequential 1 to 18
    return questionId - 1;
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
        print("ADHDScreen: Back button pressed.");
        Navigator.pop(context, null); // Signal normal back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ADHD Self-Report (Step 5)'),
          backgroundColor: _primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null), // Normal back
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(),
              const SizedBox(height: 24.0),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) => _buildQuestionBlock(index),
                separatorBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: _dividerColor, thickness: 1.0),
                    ),
              ),
              const SizedBox(height: 30.0),
              _buildNavigateButton(), // Complete button
              const SizedBox(height: 12.0),
              _buildSaveLink(), // Save link
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    const String imagePath =
        'assets/images/step5pic.png'; // Ensure path is correct
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

  Widget _buildQuestionBlock(int index) {
    final questionData = _questions[index];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    final answerIndex = _getAnswerIndex(questionId);

    // Basic validation
    if (answerIndex < 0 || answerIndex >= _answers.length) {
      print("Error: Invalid answer index $answerIndex for QID $questionId");
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // All questions are multiple choice 5 in this version
        _buildMultipleChoiceOptions(answerIndex, questionData['options']),
      ],
    );
  }

  // Builds vertical radio options
  Widget _buildMultipleChoiceOptions(int answerIndex, List<String> options) {
    return Column(
      children: List.generate(
        options.length,
        (optionIndex) => _buildVerticalOption(
          text: options[optionIndex],
          optionValue: optionIndex, // Stores 0, 1, 2, 3, 4
          questionIndexForAnswer: answerIndex,
        ),
      ),
    );
  }

  // Builds a single vertical radio option
  Widget _buildVerticalOption({
    required String text,
    required int optionValue,
    required int questionIndexForAnswer,
  }) {
    final bool isSelected = _answers[questionIndexForAnswer] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _answers[questionIndexForAnswer] = optionValue;
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom radio button
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
            // Option text
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

  Widget _buildNavigateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Make async
          if (!mounted) return;
          // Validation: Check all answered
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

          // Clear partial save
          await _clearPartialSaveFromFirestore();

          // Pop with results
          print('Step 5 (ADHD) Answers: $_answers');
          Navigator.pop(context, List<int?>.from(_answers)); // Return copy
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
        child: const Text('Complete Step 5'),
      ),
    );
  }

  Widget _buildSaveLink() {
    return Center(
      child: InkWell(
        onTap: _isSaving ? null : _saveStateToFirestore,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              _isSaving
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: _primaryColor, // <-- CORRECTED,
                    ),
                  )
                  : Text(
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