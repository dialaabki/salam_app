import 'package:flutter/material.dart';

class BipolarScreen extends StatefulWidget {
  const BipolarScreen({Key? key}) : super(key: key);

  @override
  State<BipolarScreen> createState() => _BipolarScreenState();
}

class _BipolarScreenState extends State<BipolarScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // Keep track of answers, initialized to null
  final List<int?> _answers = List.filled(17, null);

  final List<Map<String, dynamic>> _questions = [
    // (Questions list remains the same as provided)
    {
      'id': 1,
      'type': 'yes_no',
      'question':
          'Q1. Has there ever been a period of time when you were not your usual self and you felt so good or so hyper that other people thought you were not your normal self or you were so hyper that you got into trouble?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 2,
      'type': 'yes_no',
      'question':
          'Q2. Has there ever been a period of time when you were not your usual self and you were so irritable that you shouted at people or started fights or arguments?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 3,
      'type': 'yes_no',
      'question':
          'Q3. Has there ever been a period of time when you were not your usual self and you felt much more self-confident than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 4,
      'type': 'yes_no',
      'question':
          'Q4. Has there ever been a period of time when you were not your usual self and you got much less sleep than usual and found you didn\'t really miss it?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 5,
      'type': 'yes_no',
      'question':
          'Q5. Has there ever been a period of time when you were not your usual self and you were much more talkative or spoke faster than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 6,
      'type': 'yes_no',
      'question':
          'Q6. Has there ever been a period of time when you were not your usual self and thoughts raced through your head or you couldn\'t slow your mind down?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 7,
      'type': 'yes_no',
      'question':
          'Q7. Has there ever been a period of time when you were not your usual self and you were so easily distracted by things around you that you had trouble concentrating or staying on track?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 8,
      'type': 'yes_no',
      'question':
          'Q8. Has there ever been a period of time when you were not your usual self and you had much more energy than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 9,
      'type': 'yes_no',
      'question':
          'Q9. Has there ever been a period of time when you were not your usual self and you were much more active or did many more things than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 10,
      'type': 'yes_no',
      'question':
          'Q10. Has there ever been a period of time when you were not your usual self and you were much more social or outgoing than usual, for example, you telephoned friends in the middle of the night?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 11,
      'type': 'yes_no',
      'question':
          'Q11. Has there ever been a period of time when you were not your usual self and you were much more interested in sex than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 12,
      'type': 'yes_no',
      'question':
          'Q12. Has there ever been a period of time when you were not your usual self and you did things that were unusual for you or that other people might have thought were excessive, foolish, or risky?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 13,
      'type': 'yes_no',
      'question':
          'Q13. Has there ever been a period of time when you were not your usual self and spending money got you or your family in trouble?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 14,
      'type': 'yes_no',
      'question':
          'Q14. If you checked YES to more than one of the above, have several of these ever happened during the same period of time?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 15,
      'type': 'multiple_choice_4',
      'question':
          'Q15. How much of a problem did any of these cause you — like being unable to work; having family, money, or legal troubles; getting into arguments or fights?',
      'options': [
        'No problem',
        'Minor problem',
        'Moderate problem',
        'Serious problem',
      ],
    },
    {
      'id': 16,
      'type': 'yes_no',
      'question':
          'Q16. Have any of your blood relatives (ie, children, siblings, parents, grandparents, aunts, uncles) had manic-depressive illness or bipolar disorder?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 17,
      'type': 'yes_no',
      'question':
          'Q17. Has a health professional ever told you that you have manic-depressive illness or bipolar disorder?',
      'options': ['Yes', 'No'],
    },
  ];

  // Helper to get the correct index in the _answers list
  int _getAnswerIndex(int questionId) {
    // Since IDs are sequential from 1 to 17, the index is simply ID - 1
    return questionId - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Questionnaire (Step 4)'), // Added step number
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: _dividerColor, thickness: 1.0),
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
    const String imagePath = 'assets/images/step4pic.png';
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
    final answerIndex = _getAnswerIndex(questionId);

    // Safety check for answer index validity
    if (answerIndex < 0 || answerIndex >= _answers.length) {
      print(
        "Error: Invalid answer index $answerIndex for question ID: $questionId",
      );
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
          ), // Prevent text touching edge
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: 16.0, // Consistent font size
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4, // Improve readability
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        if (type == 'yes_no')
          _buildYesNoOptions(answerIndex, questionData['options'])
        else if (type == 'multiple_choice_4')
          _buildMultipleChoiceOptions(answerIndex, questionData['options']),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(int answerIndex, List<String> options) {
    // (Multiple choice build logic is the same as _buildVerticalOption)
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

  Widget _buildYesNoOptions(int answerIndex, List<String> options) {
    // (Yes/No build logic remains the same)
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(options.length, (optionIndex) {
        final bool isSelected = _answers[answerIndex] == optionIndex;
        return Padding(
          padding: EdgeInsets.only(
            right: optionIndex == 0 ? 30.0 : 0,
            left: 0, // Start from left edge
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[answerIndex] = optionIndex;
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
    final bool isSelected = _answers[questionIndexForAnswer] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _answers[questionIndexForAnswer] = optionValue;
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
          // 1. Validate: Check if all questions are answered
          bool allAnswered = !_answers.contains(null);

          if (!allAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please answer all questions before proceeding.'),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 2),
              ),
            );
            return; // Stop if not valid
          }

          // 2. If valid, print and pop with the answers
          print('Step 4 (Bipolar) Answers: $_answers');
          Navigator.pop(context, _answers); // Return the list of answers
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
        child: const Text('Complete Step 4'),
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
