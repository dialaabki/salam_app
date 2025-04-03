// lib/screens/quiz/QuizScreen.dart

import 'package:flutter/material.dart';
import 'package:salam_app/screens/quiz/Questions.dart'; // Import questions and model
import 'package:salam_app/screens/quiz/QuizResultScreen.dart'; // Import result screen

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> _questions = quizQuestions; // Use imported list
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex; // Nullable: no answer selected initially
  int _score = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  // --- Styling Constants ---
  // Using colors from your screenshots (adjust if needed)
  static const Color primaryColor = Color(
    0xFF2D7A8F,
  ); // Teal color from screenshots
  static const Color scaffoldBackgroundColor = primaryColor;
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Color(0xFF4A4A4A); // Dark text for readability
  static const Color whiteText = Colors.white;
  static const Color correctColor = Colors.green;
  static const Color wrongColor = Colors.red;
  static const Color selectedOptionColor = Color(
    0xFF2D7A8F,
  ); // Teal for selected button bg
  static const Color defaultOptionColor =
      Colors.white; // White for default button bg
  static const Color optionBorderColor = Color(0xFFEAEAEA); // Light grey border
  static const Color optionTextColor = Color(
    0xFF4A4A4A,
  ); // Dark text for options
  static const Color selectedOptionTextColor =
      Colors.white; // White text for selected option
  static const Color buttonColor = Color(
    0xFF4A90E2,
  ); // Blue button color from screenshots

  void _selectAnswer(int index) {
    if (!_showFeedback) {
      setState(() {
        _selectedAnswerIndex = index;
      });
    }
  }

  void _handleNext() {
    if (_showFeedback) {
      // --- Moving from Feedback to Next Question or Results ---
      setState(() {
        _currentQuestionIndex++;
        if (_currentQuestionIndex < _questions.length) {
          _selectedAnswerIndex = null; // Reset selection
          _showFeedback = false; // Show question view
          _isCorrect = false; // Reset correctness flag
        } else {
          // --- End of Quiz ---
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => QuizResultScreen(
                    score: _score,
                    totalQuestions: _questions.length,
                  ),
            ),
          );
        }
      });
    } else {
      // --- Moving from Question to Feedback ---
      if (_selectedAnswerIndex != null) {
        _isCorrect =
            _selectedAnswerIndex ==
            _questions[_currentQuestionIndex].correctAnswerIndex;
        if (_isCorrect) {
          _score++;
        }
        setState(() {
          _showFeedback = true; // Show feedback view
        });
      }
      // Else: do nothing if no answer is selected (button should be disabled)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent errors if quiz somehow gets called with no questions
    if (_questions.isEmpty ||
        _currentQuestionIndex >= _questions.length && !_showFeedback) {
      return const Scaffold(
        body: Center(
          child: Text("No questions available or index out of bounds."),
        ),
      );
    }

    // Use the last question for feedback view if index is out of bounds but feedback is showing
    final Question currentQuestion =
        _questions[_currentQuestionIndex < _questions.length
            ? _currentQuestionIndex
            : _questions.length - 1];
    final bool isLastQuestionFeedback =
        _currentQuestionIndex >= _questions.length;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Top Quiz Banner (Only on Question View) ---
            if (!_showFeedback) _buildQuizBanner(),

            // --- Main Content Area (Question or Feedback Card) ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 25.0,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(30.0),
                    // Keep bottom round unless feedback is showing (then it extends to navbar)
                    bottom:
                        _showFeedback
                            ? Radius.zero
                            : const Radius.circular(30.0),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child:
                      _showFeedback
                          ? _buildFeedbackView(
                            currentQuestion,
                            isLastQuestionFeedback,
                          )
                          : _buildQuestionView(currentQuestion),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildQuizBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Image.asset(
        'assets/images/quizpic.png',
        height: 80,
        errorBuilder:
            (context, error, stackTrace) => const SizedBox(height: 80),
      ),
    );
  }

  Widget _buildQuestionView(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center titles
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Title & Subtitle ---
        const Text(
          'Educational Quiz',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        const Text(
          'Test Your Knowledge & learn more',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),

        // --- Question Number and Text ---
        Align(
          // Align question text left
          alignment: Alignment.centerLeft,
          child: Text(
            'Q${_currentQuestionIndex + 1}: ${question.questionText}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 25.0),

        // --- Answer Options ---
        ...List.generate(question.options.length, (index) {
          return _buildOptionButton(
            text: question.options[index],
            index: index,
          );
        }),
        const SizedBox(height: 30.0),

        // --- Next Button ---
        Center(
          child: ElevatedButton(
            onPressed:
                _selectedAnswerIndex != null
                    ? _handleNext
                    : null, // Enable only if answer selected
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor, // Use the blue button color
              foregroundColor: whiteText,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              disabledBackgroundColor:
                  Colors.grey[300], // Grey out when disabled
              disabledForegroundColor: Colors.grey[500],
            ),
            child: const Text('Next'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildOptionButton({required String text, required int index}) {
    final bool isSelected = _selectedAnswerIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: () => _selectAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? selectedOptionColor : defaultOptionColor,
          foregroundColor:
              isSelected ? selectedOptionTextColor : optionTextColor,
          elevation: isSelected ? 2 : 1,
          minimumSize: const Size(double.infinity, 55),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: isSelected ? selectedOptionColor : optionBorderColor,
              width: 1,
            ),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildFeedbackView(Question question, bool isLastQuestion) {
    final String feedbackTitle =
        _isCorrect ? 'Your answer is Correct!' : 'Your answer is Wrong :(';
    final String imagePath =
        _isCorrect
            ? 'assets/images/rightpic.png'
            : 'assets/images/wrongpic.png';
    final String crownPath = 'assets/images/crown.png'; // Crown for correct
    final String buttonText = isLastQuestion ? 'Finish' : 'Next';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Feedback Title ---
        Text(
          feedbackTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            // Use white text on colored background for title
            color: whiteText, // Assuming title is on colored bg, adjust if not
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // --- Correct Answer (if wrong) & Educational Note ---
        Container(
          // White card container for text details
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: cardBackgroundColor, // White inner card
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (!_isCorrect)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: "the answer is : "),
                        TextSpan(
                          text: question.options[question.correctAnswerIndex],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              Text(
                'Educational Note:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                question.educationalNote,
                style: const TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // --- Feedback Image ---
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none, // Allow crown to overflow
          children: [
            Image.asset(
              imagePath,
              height: 150,
              errorBuilder:
                  (context, error, stackTrace) => const SizedBox(height: 150),
            ),
            if (_isCorrect)
              Positioned(
                top: -15, // Adjust position to place crown nicely
                child: Image.asset(
                  crownPath,
                  height: 40,
                  errorBuilder:
                      (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
        const SizedBox(height: 35),

        // --- Next/Finish Button ---
        Center(
          child: ElevatedButton(
            onPressed: _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor, // Blue button
              foregroundColor: whiteText,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(buttonText),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavBar() {
    const Color navBarColor = Color(0xFF276181);
    const Color iconColor = Color(0xFF5E94FF);
    return BottomAppBar(
      color: navBarColor,
      height: 60, // Standard height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: iconColor),
            onPressed:
                () => Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.access_time, color: iconColor),
            onPressed: () {
              // Navigate robustly: Go home first, then push reminders
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/reminders');
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: iconColor),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/activity');
            },
            tooltip: 'Activity',
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: iconColor),
            // Go back to the resource list screen
            onPressed: () => Navigator.pop(context),
            tooltip: 'Resources', // Should go back to list
          ),
          IconButton(
            icon: const Icon(Icons.person, color: iconColor),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}
