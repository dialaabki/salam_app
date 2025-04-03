// lib/screens/quiz/Questions.dart

// --- Data Model ---
class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String educationalNote;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.educationalNote,
  });
}

// --- List of Quiz Questions ---
final List<Question> quizQuestions = [
  Question(
    id: 'q1',
    questionText: 'What is stress?',
    options: [
      'A. A physical and emotional response to challenges.',
      'B. A feeling of being tired all the time.',
      'C. A medical condition with no triggers.',
      'D. Something only adults experience.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "Stress is your body's natural response to challenges or threats. It can be both positive (e.g., motivating you to meet a deadline) and negative (e.g., causing anxiety if it becomes overwhelming).",
  ),
  Question(
    id: 'q2',
    questionText:
        "What's a simple grounding technique to reduce anxiety in the moment?",
    options: [
      'A. Avoiding the feeling altogether.',
      'B. The 5-4-3-2-1 technique.',
      'C. Watching the news.',
      'D. Overanalyzing the situation.',
    ],
    correctAnswerIndex: 1,
    educationalNote:
        "The 5-4-3-2-1 technique helps ground you by focusing on your senses. Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you can taste.",
  ),
  Question(
    id: 'q3',
    questionText: 'How does chronic stress affect your body?',
    options: [
      'A. It can lead to health problems like high blood pressure.',
      'B. It boosts your immune system permanently.',
      'C. It has no long-term effects if ignored.',
      'D. It only affects your emotions, not your physical health.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "Chronic stress can have serious health impacts, including high blood pressure, weakened immunity, and mental health challenges like anxiety and depression.",
  ),
  Question(
    id: 'q4',
    questionText: 'Which activity can help you manage stress?',
    options: [
      'A. Taking a short walk outside.',
      'B. Scrolling through social media for hours.',
      'C. Drinking lots of coffee to stay alert.',
      'D. Overworking to distract yourself.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "Physical activity, like a walk outside, can reduce stress hormones and improve your mood. Spending time in nature is especially helpful for calming your mind.",
  ),
  Question(
    id: 'q5',
    questionText: 'What is anxiety?',
    options: [
      'A. A normal response to stress that can become overwhelming.',
      'B. A permanent state of worry.',
      'C. A problem that only affects certain people.',
      'D. The same as general nervousness.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "Anxiety is a normal response to stress, but when it becomes persistent or overwhelming, it might indicate an anxiety disorder that needs attention.",
  ),
  Question(
    id: 'q6',
    questionText:
        'Which breathing technique can help during an anxiety attack?',
    options: [
      'A. Box breathing (inhale for 4, hold for 4, exhale for 4, hold for 4).',
      'B. Breathing quickly to match your heartbeat.',
      'C. Holding your breath as long as possible.',
      'D. Not focusing on your breath at all.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "Box breathing is a simple yet effective technique that calms your nervous system and helps you regain control during moments of anxiety.",
  ),
  Question(
    id: 'q7',
    questionText: 'Which of the following is a common symptom of ADHD?',
    options: [
      'A. Struggling to focus on tasks or conversations.',
      'B. Sleeping more than 12 hours a day.',
      'C. Always feeling calm and organized.',
      'D. Preferring solitary activities over social interaction.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "ADHD often includes symptoms like difficulty focusing, impulsivity, and restlessness, which can affect daily life. Early identification can lead to better management.",
  ),
  Question(
    id: 'q8',
    questionText: 'What is a common compulsion in OCD?',
    options: [
      'A. Repeatedly washing hands to reduce fear of germs.',
      'B. Ignoring intrusive thoughts completely.',
      'C. Feeling sad without a reason.',
      'D. Avoiding all social interactions.',
    ],
    correctAnswerIndex: 0,
    educationalNote:
        "OCD often involves compulsions, which are repetitive behaviors like handwashing or checking to alleviate anxiety caused by intrusive thoughts.",
  ),
  Question(
    id: 'q9',
    questionText: 'Which statement about addiction is true?',
    options: [
      'A. Addiction is only caused by weak willpower.',
      'B. Addiction affects brain chemistry and is a medical condition.',
      'C. People can stop addictive behaviors without any effort.',
      'D. Addiction only applies to drugs and alcohol.',
    ],
    correctAnswerIndex: 1,
    educationalNote:
        "Addiction is a medical condition that affects brain chemistry, leading to compulsive behaviors despite harmful consequences. Professional support can help in recovery.",
  ),
  Question(
    id: 'q10',
    questionText:
        'Which of the following best describes the "fight, flight, or freeze" response to stress?',
    options: [
      'A. A conscious decision to face or avoid challenges calmly.',
      'B. An automatic physical and emotional reaction to a perceived threat.',
      'C. A strategy for managing stress through deep breathing techniques.',
      'D. A state of relaxation achieved after resolving a stressful situation.',
    ],
    correctAnswerIndex: 1,
    educationalNote:
        "The 'fight, flight, or freeze' response is your body's automatic reaction to stress or danger. It prepares you to confront (fight), escape (flight), or remain immobile (freeze) in the face of a threat.",
  ),
];
