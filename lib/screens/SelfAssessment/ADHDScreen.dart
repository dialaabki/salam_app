import 'package:flutter/material.dart';

class ADHDScreen extends StatefulWidget {
  const ADHDScreen({super.key});

  @override
  State<ADHDScreen> createState() => _ADHDScreenState();
}

class _ADHDScreenState extends State<ADHDScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // Keep track of answers, size 18, initialized to null
  final List<int?> _answers = List.filled(18, null);

  final List<Map<String, dynamic>> _questions = [
    // (Questions list remains the same as provided)
    {
      'id': 1,
      'type': 'multiple_choice_5',
      'question':
          'Q1. How often do you have trouble wrapping up the final details of a project, once the challenging parts have been done?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 2,
      'type': 'multiple_choice_5',
      'question':
          'Q2. How often do you have difficulty getting things in order when you have to do a task that requires organization?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 3,
      'type': 'multiple_choice_5',
      'question':
          'Q3. How often do you have problems remembering appointments or obligations?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 4,
      'type': 'multiple_choice_5',
      'question':
          'Q4. When you have a task that requires a lot of thought, how often do you avoid or delay getting started?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 5,
      'type': 'multiple_choice_5',
      'question':
          'Q5. How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 6,
      'type': 'multiple_choice_5',
      'question':
          'Q6. How often do you feel overly active and compelled to do things, like you were driven by a motor?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 7,
      'type': 'multiple_choice_5',
      'question':
          'Q7. How often do you make careless mistakes when you have to work on a boring or difficult project?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 8,
      'type': 'multiple_choice_5',
      'question':
          'Q8. How often do you have difficulty keeping your attention when you are doing boring or repetitive work?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 9,
      'type': 'multiple_choice_5',
      'question':
          'Q9. How often do you have difficulty concentrating on what people say to you, even when they are speaking to you directly?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 10,
      'type': 'multiple_choice_5',
      'question':
          'Q10. How often do you misplace or have difficulty finding things at home or at work?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 11,
      'type': 'multiple_choice_5',
      'question':
          'Q11. How often are you distracted by activity or noise around you?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 12,
      'type': 'multiple_choice_5',
      'question':
          'Q12. How often do you leave your seat in meetings or other situations in which you are expected to remain seated?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 13,
      'type': 'multiple_choice_5',
      'question': 'Q13. How often do you feel restless or fidgety?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 14,
      'type': 'multiple_choice_5',
      'question':
          'Q14. How often do you have difficulty unwinding and relaxing when you have time to yourself?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 15,
      'type': 'multiple_choice_5',
      'question':
          'Q15. How often do you find yourself talking too much when you are in social situations?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 16,
      'type': 'multiple_choice_5',
      'question':
          'Q16. When you’re in a conversation, how often do you find yourself finishing the sentences of the people you are talking to, before they can finish them themselves?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 17,
      'type': 'multiple_choice_5',
      'question':
          'Q17. How often do you have difficulty waiting your turn in situations when turn taking is required?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
    {
      'id': 18,
      'type': 'multiple_choice_5',
      'question': 'Q18. How often do you interrupt others when they are busy?',
      'options': ['Never', 'Rarely', 'Sometimes', 'Often', 'Very Often'],
    },
  ];

  // Helper to get the correct index in the _answers list
  int _getAnswerIndex(int questionId) {
    // Since IDs are sequential from 1 to 18, the index is ID - 1
    return questionId - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHD Self-Report (Step 5)'), // Added step number
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
    const String imagePath = 'assets/images/step5pic.png';
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
        // Only one type here, directly call the builder
        _buildMultipleChoiceOptions(answerIndex, questionData['options']),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(int answerIndex, List<String> options) {
    // (This is the same as _buildVerticalOption)
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
          print('Step 5 (ADHD) Answers: $_answers');
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
        child: const Text('Complete Step 5'),
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
