import 'package:flutter/material.dart';

class AnxietyScreen extends StatefulWidget {
  const AnxietyScreen({Key? key}) : super(key: key);
  @override
  State<AnxietyScreen> createState() => _AnxietyScreenState();
}

class _AnxietyScreenState extends State<AnxietyScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _introTextColor = const Color(0xFF276181);
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // Keep track of answers, initialized to null
  final List<int?> _answers = List.filled(8, null);

  final List<Map<String, dynamic>> _questions = [
    // (Questions list remains the same as provided)
    {
      'question': 'Q1. Feeling nervous, anxious, or on edge?',
      'options': [
        'Not at all',
        'Several days',
        'More than half the days',
        'Nearly every day',
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
        'Not difficult at all',
        'Somewhat difficult',
        'Very difficult',
        'Extremely difficult',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anxiety Assessment (Step 2)'), // Added step number
        backgroundColor: _primaryColor, // Use primary color for AppBar
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
    const String imagePath = 'assets/images/step2pic.png';
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

  Widget _buildIntroText() {
    // (Intro text build logic remains the same)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Over the last two weeks, how often have you been bothered by the following problems?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: _introTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuestionBlock(int questionIndex) {
    // (Question block build logic remains the same)
    bool isLastQuestion = questionIndex == _questions.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questions[questionIndex]['question'],
          style: TextStyle(
            fontSize: isLastQuestion ? 16.0 : 17.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: isLastQuestion ? 1.4 : null,
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children: List.generate(
            _questions[questionIndex]['options'].length,
            (optionIndex) => _buildOption(
              text: _questions[questionIndex]['options'][optionIndex],
              optionValue: optionIndex,
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
    // (Option build logic remains the same)
    final bool isSelected = _answers[questionIndex] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
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
          print('Step 2 (Anxiety) Answers: $_answers');
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
        child: const Text('Complete Step 2'),
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
