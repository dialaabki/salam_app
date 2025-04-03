import 'package:flutter/material.dart';

class OCDScreen extends StatefulWidget {
  const OCDScreen({super.key});

  @override
  State<OCDScreen> createState() => _OCDScreenState();
}

class _OCDScreenState extends State<OCDScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;
  final Color _checklistLabelColor = Colors.grey.shade600;

  // Answers for Q1-10 (severity) and Q15-18 (yes/no), total 14
  final List<int?> _severityAndFinalAnswers = List.filled(14, null);
  // Answers for checklist items Q1-11 (IDs 11-21)
  late Map<int, Map<String, bool>> _checklistAnswers;

  // Combined questions list (remains the same as provided)
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'type': 'multiple_choice_5',
      'question':
          'Q1. How much of your time is occupied by obsessive thoughts?',
      'options': [
        'None',
        'Less than 1 hr/day...',
        '1 to 3 hrs/day...',
        'Greater than 3 and up to 8 hrs/day...',
        'Greater than 8 hrs/day...',
      ],
    },
    {
      'id': 2,
      'type': 'multiple_choice_5',
      'question':
          'Q2. How do obsessive thoughts impact your daily responsibilities?',
      'options': [
        'None',
        'Slight interference...',
        'Definite interference...',
        'Causes substantial impairment...',
        'Incapacitating',
      ],
    },
    {
      'id': 3,
      'type': 'multiple_choice_5',
      'question': 'Q3. How much distress do your obsessive thoughts cause you?',
      'options': [
        'None',
        'Not too disturbing',
        'Disturbing, but still manageable',
        'Very disturbing',
        'Near constant and disabling distress',
      ],
    },
    {
      'id': 4,
      'type': 'multiple_choice_5',
      'question':
          'Q4. How much of an effort do you make to resist the obsessive thoughts?',
      'options': [
        'Try to resist all the time',
        'Try to resist most...',
        'Make some effort...',
        'Yield to all obsessions...',
        'Completely and willingly yield...',
      ],
    },
    {
      'id': 5,
      'type': 'multiple_choice_5',
      'question':
          'Q5. How much control do you have over your obsessive thoughts?',
      'options': [
        'Complete control',
        'Usually able to stop...',
        'Sometimes able to stop...',
        'Rarely successful...',
        'Obsessions are completely involuntary',
      ],
    },
    {
      'id': 6,
      'type': 'multiple_choice_5',
      'question':
          'Q6. How much time do you spend performing compulsive behaviors?',
      'options': [
        'None',
        'Less than 1 hr/day...',
        'From 1 to 3 hrs/day...',
        'More than 3 and up to 8 hrs/day...',
        'More than 8 hrs/day...',
      ],
    },
    {
      'id': 7,
      'type': 'multiple_choice_5',
      'question':
          'Q7. How much do your compulsive behaviors interfere with your work, school, social activities?',
      'options': [
        'None',
        'Slight interference...',
        'Definite interference...',
        'Causes substantial impairment...',
        'Incapacitating',
      ],
    },
    {
      'id': 8,
      'type': 'multiple_choice_5',
      'question':
          'Q8. How anxious would you become if prevented from performing your compulsion(s)?',
      'options': [
        'None',
        'Only slightly anxious...',
        'Anxiety would mount...',
        'Prominent and very disturbing...',
        'Incapacitating anxiety...',
      ],
    },
    {
      'id': 9,
      'type': 'multiple_choice_5',
      'question':
          'Q9. How much of an effort do you make to resist the compulsions?',
      'options': [
        'Always try to resist',
        'Try to resist most...',
        'Make some effort...',
        'Yield to almost all...',
        'Completely and willingly yield...',
      ],
    },
    {
      'id': 10,
      'type': 'multiple_choice_5',
      'question':
          'Q10. How strong is the drive to perform the compulsive behavior?',
      'options': [
        'Complete control',
        'Pressure to perform but usually able...',
        'Strong pressure...',
        'Very strong drive...',
        'Drive completely involuntary...',
      ],
    },
    {
      'id': 11,
      'type': 'checklist',
      'question': 'Q11. (Checklist) Fear of harming self or others.',
    }, // Renamed for clarity
    {
      'id': 12,
      'type': 'checklist',
      'question':
          'Q12. (Checklist) Fear of causing catastrophic events (e.g., accidents, fires).',
    },
    {
      'id': 13,
      'type': 'checklist',
      'question':
          'Q13. (Checklist) Intrusive or unwanted sexual thoughts or impulses.',
    },
    {
      'id': 14,
      'type': 'checklist',
      'question':
          'Q14. (Checklist) Concerns about dirt, germs, or contamination.',
    },
    {
      'id': 15,
      'type': 'checklist',
      'question':
          'Q15. (Checklist) Obsessive thoughts about morality, religion, or perfectionism.',
    },
    {
      'id': 16,
      'type': 'checklist',
      'question':
          'Q16. (Checklist) Overwhelming need for symmetry, order, or exactness.',
    },
    {
      'id': 17,
      'type': 'checklist',
      'question':
          'Q17. (Checklist) Persistent intrusive thoughts about nonsensical sounds, images, or ideas.',
    },
    {
      'id': 18,
      'type': 'checklist',
      'question':
          'Q18. (Checklist) Excessive cleaning or washing rituals (e.g., handwashing, showering).',
    },
    {
      'id': 19,
      'type': 'checklist',
      'question':
          'Q19. (Checklist) Repeated checking behaviors (e.g., locks, appliances, safety).',
    },
    {
      'id': 20,
      'type': 'checklist',
      'question':
          'Q20. (Checklist) Repeating actions (e.g., rereading, rewriting, or retracing steps).',
    },
    {
      'id': 21,
      'type': 'checklist',
      'question':
          'Q21. (Checklist) Constant rearranging or ordering of items for symmetry or precision.',
    },
    {
      'id': 22,
      'type': 'yes_no',
      'question':
          'Q22. Do your thoughts or behaviors interfere with daily responsibilities (e.g., work, family)?',
      'options': ['Yes', 'No'],
    }, // Renumbered for clarity in UI
    {
      'id': 23,
      'type': 'yes_no',
      'question':
          'Q23. Do you feel relief or satisfaction after engaging in compulsive behaviors?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 24,
      'type': 'yes_no',
      'question':
          'Q24. Do you avoid certain situations or objects to prevent obsessions or compulsions?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 25,
      'type': 'yes_no',
      'question':
          'Q25. Do you feel your life is being controlled by these thoughts or behaviors?',
      'options': ['Yes', 'No'],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize checklist answers map
    _checklistAnswers = {
      for (var q in _questions)
        if (q['type'] == 'checklist')
          q['id'] as int: {'current': false, 'past': false},
    };
  }

  // Helper to map question ID to the correct index in _severityAndFinalAnswers
  int _getSeverityAnswerIndex(int questionId) {
    if (questionId >= 1 && questionId <= 10) {
      // Q1-10 map to indices 0-9
      return questionId - 1;
    } else if (questionId >= 22 && questionId <= 25) {
      // Q22-25 map to indices 10-13
      return questionId - 22 + 10;
    }
    // Should not happen with valid IDs
    print("Error: Could not find answer index for Question ID $questionId");
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCD Assessment (Step 3)'), // Added step number
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false), // Pop with false
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
              itemBuilder: (context, index) {
                return _buildQuestionBlock(index);
              },
              separatorBuilder: (context, index) {
                // Only add visible dividers between non-checklist groups
                final currentType = _questions[index]['type'];
                final nextType =
                    (index + 1 < _questions.length)
                        ? _questions[index + 1]['type']
                        : null;
                bool hideDivider =
                    currentType == 'checklist' || nextType == 'checklist';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    color: hideDivider ? Colors.transparent : _dividerColor,
                    thickness: 1.0,
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
    );
  }

  Widget _buildHeaderImage() {
    // (Header image build logic remains the same)
    const String imagePath = 'assets/images/step3pic.png';
    return Center(
      child: Image.asset(
        imagePath,
        height: 60, // Example height
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Container(
            height: 60,
            color: _inactiveColor.withOpacity(0.5),
            child: const Center(
              child: Text(
                'Image Error',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
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

    // Add grouping headers for clarity
    Widget? header;
    if (questionId == 1) {
      header = _buildSectionHeader("Obsession Severity (Q1-5)");
    } else if (questionId == 6) {
      header = _buildSectionHeader("Compulsion Severity (Q6-10)");
    } else if (questionId == 11) {
      header = _buildSectionHeader("Symptom Checklist (Q11-21)");
    } else if (questionId == 22) {
      header = _buildSectionHeader("Impact & Control (Q22-25)");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header, // Display header if applicable
        Padding(
          // Add padding to question text
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            questionText,
            style: TextStyle(
              fontSize:
                  (type == 'checklist')
                      ? 16.0
                      : 17.0, // Slightly smaller for checklist items
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
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
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
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
    if (answerIndex == -1) return const SizedBox.shrink(); // Safety check
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
    // Ensure the key exists before accessing
    if (!_checklistAnswers.containsKey(questionId)) {
      print("Error: Checklist ID $questionId not found in map.");
      return const SizedBox.shrink();
    }
    bool isCurrent = _checklistAnswers[questionId]!['current']!;
    bool isPast = _checklistAnswers[questionId]!['past']!;

    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
      ), // Indent checklist options slightly
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildChecklistItem('Current', isCurrent, (value) {
            setState(() {
              _checklistAnswers[questionId]!['current'] = value ?? false;
            });
          }),
          const SizedBox(width: 40),
          _buildChecklistItem('Past', isPast, (value) {
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
    // (Checklist item build logic remains the same)
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        // Add padding for better tap area
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24, // Slightly larger tap target
              height: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: _primaryColor,
                side: BorderSide(color: _inactiveColor, width: 2),
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

  Widget _buildYesNoOptions(int questionId, List<String> options) {
    final answerIndex = _getSeverityAnswerIndex(questionId);
    if (answerIndex == -1) return const SizedBox.shrink(); // Safety check

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(options.length, (optionIndex) {
        final bool isSelected =
            _severityAndFinalAnswers[answerIndex] == optionIndex;
        return Padding(
          padding: EdgeInsets.only(
            right: optionIndex == 0 ? 30.0 : 0, // Space between Yes and No
            left: 0, // Start from left edge
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _severityAndFinalAnswers[answerIndex] = optionIndex;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
    // (Vertical option build logic remains the same)
    if (questionIndexForAnswer < 0 ||
        questionIndexForAnswer >= _severityAndFinalAnswers.length) {
      print("Error: Invalid questionIndexForAnswer: $questionIndexForAnswer");
      return const SizedBox.shrink();
    }
    final bool isSelected =
        _severityAndFinalAnswers[questionIndexForAnswer] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
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
        // ***MODIFIED onPressed***
        onPressed: () {
          // 1. Validate: Check if Q1-10 and Q22-25 are answered
          bool severityAnswered =
              !_severityAndFinalAnswers.sublist(0, 10).contains(null);
          bool finalAnswered =
              !_severityAndFinalAnswers
                  .sublist(10, 14)
                  .contains(null); // Q22-25 -> indices 10-13

          if (!severityAnswered || !finalAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please answer all questions in sections Q1-10 and Q22-25.',
                ),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return; // Stop if not valid
          }

          // 2. If valid, prepare results map and pop
          final results = {
            'severityAndFinalAnswers': _severityAndFinalAnswers,
            'checklistAnswers': _checklistAnswers,
          };
          print('Step 3 (OCD) Answers: $results');
          Navigator.pop(context, results); // Return the map of answers
        },
        // *** END MODIFIED onPressed***
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
    // (Save link logic remains the same)
    return Center(
      child: InkWell(
        onTap: () {
          print('Save and continue later tapped');
          // TODO: Implement save functionality if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Save functionality not implemented yet.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Text(
          'Save and continue later >>',
          style: TextStyle(
            fontSize: 14,
            color: _primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: _primaryColor,
          ),
        ),
      ),
    );
  }
}
