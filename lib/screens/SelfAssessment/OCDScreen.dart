// ocdscreen.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // Keep for potential future use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import keys from SelfAssessmentScreen
// Adjust the import path if necessary
import 'SelfAssessmentScreen.dart'
    show keyOCD, firestoreCollection, fieldPartialSaves;

class OCDScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState;
  const OCDScreen({super.key, this.initialState});

  @override
  State<OCDScreen> createState() => _OCDScreenState();
}

class _OCDScreenState extends State<OCDScreen> {
  // --- UI Styling Constants ---
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;
  final Color _checklistLabelColor = Colors.grey.shade600;

  // --- State Variables ---
  List<int?> _severityAndFinalAnswers = List.filled(14, null);
  Map<int, Map<String, bool>> _checklistAnswers = {};

  // --- Firebase Instances and State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false;

  // --- Questions Data ---
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'type': 'multiple_choice_5',
      'question':
          'Q1. How much of your time is occupied by obsessive thoughts?',
      'options': [
        'None (0)',
        'Less than 1 hr/day... (1)',
        '1 to 3 hrs/day... (2)',
        'Greater than 3 and up to 8 hrs/day... (3)',
        'Greater than 8 hrs/day... (4)',
      ],
    },
    {
      'id': 2,
      'type': 'multiple_choice_5',
      'question':
          'Q2. How much do obsessive thoughts interfere with your social, work, or role functioning?',
      'options': [
        'None (0)',
        'Slight interference... (1)',
        'Definite interference... (2)',
        'Causes substantial impairment... (3)',
        'Incapacitating (4)',
      ],
    },
    {
      'id': 3,
      'type': 'multiple_choice_5',
      'question': 'Q3. How much distress do your obsessive thoughts cause you?',
      'options': [
        'None (0)',
        'Not too disturbing (1)',
        'Disturbing, but still manageable (2)',
        'Very disturbing (3)',
        'Near constant and disabling distress (4)',
      ],
    },
    {
      'id': 4,
      'type': 'multiple_choice_5',
      'question':
          'Q4. How much of an effort do you make to resist the obsessive thoughts?',
      'options': [
        'Try to resist all the time (0)',
        'Try to resist most... (1)',
        'Make some effort... (2)',
        'Yield to all obsessions... (3)',
        'Completely and willingly yield... (4)',
      ],
    },
    {
      'id': 5,
      'type': 'multiple_choice_5',
      'question':
          'Q5. How much control do you have over your obsessive thoughts?',
      'options': [
        'Complete control (0)',
        'Usually able to stop... (1)',
        'Sometimes able to stop... (2)',
        'Rarely successful... (3)',
        'Obsessions are completely involuntary (4)',
      ],
    },
    {
      'id': 6,
      'type': 'multiple_choice_5',
      'question':
          'Q6. How much time do you spend performing compulsive behaviors?',
      'options': [
        'None (0)',
        'Less than 1 hr/day... (1)',
        'From 1 to 3 hrs/day... (2)',
        'More than 3 and up to 8 hrs/day... (3)',
        'More than 8 hrs/day... (4)',
      ],
    },
    {
      'id': 7,
      'type': 'multiple_choice_5',
      'question':
          'Q7. How much do your compulsive behaviors interfere with your work, school, social, or role functioning?',
      'options': [
        'None (0)',
        'Slight interference... (1)',
        'Definite interference... (2)',
        'Causes substantial impairment... (3)',
        'Incapacitating (4)',
      ],
    },
    {
      'id': 8,
      'type': 'multiple_choice_5',
      'question':
          'Q8. How anxious/distressed would you become if prevented from performing your compulsion(s)?',
      'options': [
        'None (0)',
        'Only slightly anxious... (1)',
        'Anxiety would mount... (2)',
        'Prominent and very disturbing... (3)',
        'Incapacitating anxiety... (4)',
      ],
    },
    {
      'id': 9,
      'type': 'multiple_choice_5',
      'question':
          'Q9. How much of an effort do you make to resist the compulsions?',
      'options': [
        'Always try to resist (0)',
        'Try to resist most... (1)',
        'Make some effort... (2)',
        'Yield to almost all... (3)',
        'Completely and willingly yield... (4)',
      ],
    },
    {
      'id': 10,
      'type': 'multiple_choice_5',
      'question':
          'Q10. How much control do you have over the compulsions? (How strong is the drive?)',
      'options': [
        'Complete control (0)',
        'Pressure to perform but usually able... (1)',
        'Strong pressure... (2)',
        'Very strong drive... (3)',
        'Drive completely involuntary... (4)',
      ],
    },
    {
      'id': 11,
      'type': 'checklist',
      'question':
          'Q11. (Checklist) Aggressive Obsessions: Fear might harm self',
    },
    {
      'id': 12,
      'type': 'checklist',
      'question':
          'Q12. (Checklist) Aggressive Obsessions: Fear might harm others',
    },
    {
      'id': 13,
      'type': 'checklist',
      'question':
          'Q13. (Checklist) Aggressive Obsessions: Violent or horrific images',
    },
    {
      'id': 14,
      'type': 'checklist',
      'question':
          'Q14. (Checklist) Aggressive Obsessions: Fear of blurting out obscenities or insults',
    },
    {
      'id': 15,
      'type': 'checklist',
      'question':
          'Q15. (Checklist) Aggressive Obsessions: Fear of doing something else embarrassing',
    },
    {
      'id': 16,
      'type': 'checklist',
      'question':
          'Q16. (Checklist) Contamination Obsessions: Concerns with dirt, germs, or viruses',
    },
    {
      'id': 17,
      'type': 'checklist',
      'question':
          'Q17. (Checklist) Contamination Obsessions: Excessive concern with household items (cleansers, solvents)',
    },
    {
      'id': 18,
      'type': 'checklist',
      'question':
          'Q18. (Checklist) Contamination Obsessions: Excessive concern with bodily waste or secretions',
    },
    {
      'id': 19,
      'type': 'checklist',
      'question':
          'Q19. (Checklist) Sexual Obsessions: Forbidden or perverse sexual thoughts, images, or impulses',
    },
    {
      'id': 20,
      'type': 'checklist',
      'question': 'Q20. (Checklist) Hoarding/Saving Obsessions',
    },
    {
      'id': 21,
      'type': 'checklist',
      'question': 'Q21. (Checklist) Religious Obsessions (Scrupulosity)',
    },
    {
      'id': 22,
      'type': 'checklist',
      'question':
          'Q22. (Checklist) Obsession with need for symmetry or exactness',
    },
    {
      'id': 23,
      'type': 'checklist',
      'question':
          'Q23. (Checklist) Miscellaneous Obsessions: Need to know or remember',
    },
    {
      'id': 24,
      'type': 'checklist',
      'question':
          'Q24. (Checklist) Miscellaneous Obsessions: Fear of saying certain things',
    },
    {
      'id': 25,
      'type': 'checklist',
      'question': 'Q25. (Checklist) Cleaning/Washing Compulsions',
    },
    {
      'id': 26,
      'type': 'checklist',
      'question':
          'Q26. (Checklist) Checking Compulsions (locks, stove, appliances, etc.)',
    },
    {
      'id': 27,
      'type': 'checklist',
      'question': 'Q27. (Checklist) Repeating Rituals',
    },
    {
      'id': 28,
      'type': 'checklist',
      'question': 'Q28. (Checklist) Counting Compulsions',
    },
    {
      'id': 29,
      'type': 'checklist',
      'question': 'Q29. (Checklist) Ordering/Arranging Compulsions',
    },
    {
      'id': 30,
      'type': 'checklist',
      'question': 'Q30. (Checklist) Hoarding/Collecting Compulsions',
    },
    {
      'id': 31,
      'type': 'checklist',
      'question':
          'Q31. (Checklist) Miscellaneous Compulsions (e.g., excessive list making)',
    },
    {
      'id': 32,
      'type': 'yes_no',
      'question':
          'Q32. Do your thoughts or behaviors interfere with daily responsibilities (e.g., work, family)?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 33,
      'type': 'yes_no',
      'question':
          'Q33. Do you feel relief or satisfaction after engaging in compulsive behaviors?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 34,
      'type': 'yes_no',
      'question':
          'Q34. Do you avoid certain situations or objects to prevent obsessions or compulsions?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 35,
      'type': 'yes_no',
      'question':
          'Q35. Do you feel your life is being controlled by these thoughts or behaviors?',
      'options': ['Yes', 'No'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _checklistAnswers = {
      for (var q in _questions)
        if (q['type'] == 'checklist')
          q['id'] as int: {'current': false, 'past': false},
    };
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _userProgressDocRef = _firestore
          .collection(firestoreCollection)
          .doc(_currentUser!.uid);
      _initializeState();
    } else {
      print("Error: CurrentUser is null in OCDScreen initState");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: User not logged in."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _initializeState() {
    if (widget.initialState != null && mounted) {
      print("OCDScreen: Initializing state from passed data.");
      try {
        Map<String, dynamic> loadedState = widget.initialState!;
        if (loadedState.containsKey('severityAndFinalAnswers') &&
            loadedState['severityAndFinalAnswers'] is List) {
          List<dynamic> dynamicList = loadedState['severityAndFinalAnswers'];
          List<int?> loadedAnswers =
              dynamicList.map((item) => item is int ? item : null).toList();
          if (loadedAnswers.length == _severityAndFinalAnswers.length) {
            setState(() {
              _severityAndFinalAnswers = loadedAnswers;
            });
            print("OCDScreen: Initialized severityAndFinalAnswers.");
          } else {
            print(
              "OCDScreen: Initial severityAndFinalAnswers length mismatch. Using defaults.",
            );
          }
        } else {
          print(
            "OCDScreen: Initial state missing 'severityAndFinalAnswers' or not a list. Using defaults.",
          );
        }

        if (loadedState.containsKey('checklistAnswers') &&
            loadedState['checklistAnswers'] is Map) {
          Map<String, dynamic> rawChecklist = Map<String, dynamic>.from(
            loadedState['checklistAnswers'],
          );
          Map<int, Map<String, bool>> loadedChecklist = {};
          bool dataValid = true;
          rawChecklist.forEach((key, value) {
            try {
              int questionId = int.parse(key);
              if (value is Map &&
                  value.containsKey('current') &&
                  value['current'] is bool &&
                  value.containsKey('past') &&
                  value['past'] is bool) {
                if (_checklistAnswers.containsKey(questionId)) {
                  loadedChecklist[questionId] = {
                    'current': value['current'],
                    'past': value['past'],
                  };
                } else {
                  print(
                    "OCDScreen: Initial checklist item ID $questionId not found in current questions. Ignoring.",
                  );
                }
              } else {
                print(
                  "OCDScreen: Initial checklist item '$key' has invalid format. Ignoring.",
                );
                dataValid = false;
              }
            } catch (e) {
              print(
                "OCDScreen: Error parsing initial checklist key '$key': $e. Ignoring.",
              );
              dataValid = false;
            }
          });

          if (dataValid && loadedChecklist.isNotEmpty) {
            setState(() {
              loadedChecklist.forEach((key, value) {
                if (_checklistAnswers.containsKey(key)) {
                  _checklistAnswers[key] = value;
                }
              });
            });
            print("OCDScreen: Initialized checklistAnswers from saved data.");
          } else if (!dataValid) {
            print(
              "OCDScreen: Some initial checklist data was invalid. Using defaults for those.",
            );
          } else {
            print(
              "OCDScreen: No valid initial checklist data found for current questions. Using defaults.",
            );
          }
        } else {
          print(
            "OCDScreen: Initial state missing 'checklistAnswers' or not a map. Using defaults.",
          );
        }
      } catch (e) {
        print(
          "OCDScreen: Error parsing initial state data: $e. Using defaults for all.",
        );
        setState(() {
          _severityAndFinalAnswers = List.filled(14, null);
          _checklistAnswers = {
            for (var q in _questions)
              if (q['type'] == 'checklist')
                q['id'] as int: {'current': false, 'past': false},
          };
        });
      }
    } else {
      print("OCDScreen: No initial state passed. Using defaults.");
    }
  }

  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print("OCDScreen Error: Cannot save state, user ref is null.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Not logged in?'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = true);

    Map<String, Map<String, bool>> checklistForFirestore = _checklistAnswers
        .map((key, value) => MapEntry(key.toString(), value));
    final Map<String, dynamic> currentStateForFirestore = {
      'severityAndFinalAnswers': _severityAndFinalAnswers,
      'checklistAnswers': checklistForFirestore,
    };
    final String fieldPath = '$fieldPartialSaves.$keyOCD';

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyOCD: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPath]));
      print("OCDScreen: Partial state saved to Firestore.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, 'saved');
      }
    } catch (e) {
      print("OCDScreen: Error saving state to Firestore: $e");
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
    final String fieldPath = '$fieldPartialSaves.$keyOCD';
    try {
      await _userProgressDocRef!.update({fieldPath: FieldValue.delete()});
      print("OCDScreen: Cleared partial save for '$keyOCD' from Firestore.");
    } catch (e) {
      print(
        "OCDScreen: Error clearing partial save for '$keyOCD' from Firestore: $e",
      );
    }
  }

  int _getSeverityAnswerIndex(int questionId) {
    if (questionId >= 1 && questionId <= 10) return questionId - 1;
    if (questionId >= 32 && questionId <= 35) return questionId - 32 + 10;
    print(
      "Warning: Unexpected question ID $questionId for severity/final answer mapping.",
    );
    return -1;
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

    final checklistIds =
        _questions
            .where((q) => q['type'] == 'checklist')
            .map((q) => q['id'] as int)
            .toSet();

    return WillPopScope(
      onWillPop: () async {
        print("OCDScreen: Back button pressed.");
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OCD Assessment (Step 3)'),
          backgroundColor: _primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null),
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
                separatorBuilder: (context, index) {
                  final currentId = _questions[index]['id'] as int;
                  final nextId =
                      (index + 1 < _questions.length)
                          ? _questions[index + 1]['id'] as int
                          : -1;
                  bool hideDivider =
                      checklistIds.contains(currentId) ||
                      (nextId != -1 && checklistIds.contains(nextId));
                  double verticalPadding = 16.0;
                  if (checklistIds.contains(currentId) &&
                      (nextId != -1 && !checklistIds.contains(nextId))) {
                    verticalPadding = 24.0;
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    child: Divider(
                      color: hideDivider ? Colors.transparent : _dividerColor,
                      thickness: hideDivider ? 0 : 1.0,
                      height: hideDivider ? 0 : 1.0,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30.0),
              _buildNavigateButton(),
              const SizedBox(height: 12.0),
              _buildSaveLink(),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    const String imagePath = 'assets/images/step3pic.png';
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
    final String type = questionData['type'];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    Widget? header;
    if (questionId == 1)
      header = _buildSectionHeader("Obsession Severity (Q1-5)");
    else if (questionId == 6)
      header = _buildSectionHeader("Compulsion Severity (Q6-10)");
    else if (questionId == 11)
      header = _buildSectionHeader("Symptom Checklist (Q11-31)");
    else if (questionId == 32)
      header = _buildSectionHeader("Impact & Control (Q32-35)");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header,
        Padding(
          padding: EdgeInsets.only(
            top: (header == null && type != 'checklist') ? 0 : 8.0,
          ),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: (type == 'checklist') ? 15.5 : 17.0,
              fontWeight:
                  (type == 'checklist') ? FontWeight.w500 : FontWeight.w600,
              color: _questionTextColor,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: (type == 'checklist') ? 8.0 : 16.0),
        if (type == 'multiple_choice_5')
          _buildMultipleChoiceOptions(questionId, questionData['options'])
        else if (type == 'checklist')
          _buildChecklistOptions(questionId)
        else if (type == 'yes_no')
          _buildYesNoOptions(questionId, questionData['options']),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(int questionId, List<String> options) {
    final answerIndex = _getSeverityAnswerIndex(questionId);
    if (answerIndex < 0 || answerIndex >= _severityAndFinalAnswers.length) {
      print("Error: Invalid answer index $answerIndex for QID $questionId");
      return const SizedBox.shrink();
    }
    return Column(
      children: List.generate(
        options.length,
        (optionIndex) => _buildVerticalOption(
          text: options[optionIndex],
          optionValue: optionIndex,
          questionIndexForAnswer: answerIndex,
        ),
      ),
    );
  }

  Widget _buildChecklistOptions(int questionId) {
    if (!_checklistAnswers.containsKey(questionId)) {
      print("Error rendering checklist: ID $questionId not found in map.");
      return const SizedBox.shrink();
    }
    bool isCurrent = _checklistAnswers[questionId]!['current'] ?? false;
    bool isPast = _checklistAnswers[questionId]!['past'] ?? false;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildChecklistItem('Current', isCurrent, (value) {
            if (!mounted) return;
            setState(() {
              _checklistAnswers[questionId]!['current'] = value ?? false;
            });
          }),
          const SizedBox(width: 40),
          _buildChecklistItem('Past', isPast, (value) {
            if (!mounted) return;
            setState(() {
              _checklistAnswers[questionId]!['past'] = value ?? false;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    String label,
    bool isChecked,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: _primaryColor,
                side: BorderSide(color: _inactiveColor, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: _checklistLabelColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Builds horizontal Yes/No radio options
  Widget _buildYesNoOptions(int questionId, List<String> options) {
    final answerIndex = _getSeverityAnswerIndex(questionId);
    // Check if the mapping returned a valid index
    if (answerIndex < 0 || answerIndex >= _severityAndFinalAnswers.length) {
      print("Error: Invalid answer index $answerIndex for QID $questionId");
      return const SizedBox.shrink(); // Don't render if index is invalid
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align options to the left
      children: List.generate(options.length, (optionIndex) {
        // Yes = 0, No = 1. Check if current answer matches this option's value.
        final bool isSelected =
            _severityAndFinalAnswers[answerIndex] == optionIndex;
        return Padding(
          // Add space only between Yes and No
          padding: EdgeInsets.only(right: optionIndex == 0 ? 30.0 : 0),
          child: InkWell(
            onTap: () {
              if (!mounted) return;
              setState(() {
                // Update the list at the calculated index
                _severityAndFinalAnswers[answerIndex] = optionIndex;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom radio button
                Container(
                  width: 22.0,
                  height: 22.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _borderColor : _inactiveColor,
                      width: 2.0,
                    ),
                  ),
                  // --- THIS IS THE CORRECTED PART ---
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
                  // --- THE DUPLICATE CHILD BLOCK HAS BEEN REMOVED ---
                ),
                // Option Text (Yes/No)
                Text(
                  options[optionIndex],
                  style: TextStyle(fontSize: 15.0, color: _optionTextColor),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerticalOption({
    required String text,
    required int optionValue,
    required int questionIndexForAnswer,
  }) {
    if (questionIndexForAnswer < 0 ||
        questionIndexForAnswer >= _severityAndFinalAnswers.length) {
      return const SizedBox.shrink();
    }
    final bool isSelected =
        _severityAndFinalAnswers[questionIndexForAnswer] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            if (questionIndexForAnswer >= 0 &&
                questionIndexForAnswer < _severityAndFinalAnswers.length) {
              _severityAndFinalAnswers[questionIndexForAnswer] = optionValue;
            }
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

  Widget _buildNavigateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (!mounted) return;
          bool severityAnswered =
              !_severityAndFinalAnswers.sublist(0, 10).contains(null);
          bool finalAnswered =
              !_severityAndFinalAnswers.sublist(10, 14).contains(null);
          if (!severityAnswered || !finalAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please answer all questions in sections Q1-10 and Q32-35.',
                ),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
          await _clearPartialSaveFromFirestore();
          final Map<String, Map<String, bool>> checklistForResults =
              _checklistAnswers.map(
                (key, value) => MapEntry(key.toString(), value),
              );
          final results = {
            'severityAndFinalAnswers': List<int?>.from(
              _severityAndFinalAnswers,
            ),
            'checklistAnswers': checklistForResults,
          };
          print('Step 3 (OCD) Answers: $results');
          Navigator.pop(context, results);
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
        child: const Text('Complete Step 3'),
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
                      color: _primaryColor, // Corrected
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