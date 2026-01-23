import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class AIFeaturesScreen extends StatefulWidget {
  const AIFeaturesScreen({super.key});

  @override
  State<AIFeaturesScreen> createState() => _AIFeaturesScreenState();
}

class _AIFeaturesScreenState extends State<AIFeaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _summarizerController = TextEditingController();
  final TextEditingController _ttsController = TextEditingController();
  final TextEditingController _quizController = TextEditingController();

  final FlutterTts _flutterTts = FlutterTts();

  // Summary output (RichText with bold keywords)
  List<TextSpan> _summarySpans = [];

  // Quiz variables
  List<QuizQuestion> _questions = [];
  Map<int, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _summarizerController.dispose();
    _ttsController.dispose();
    _quizController.dispose();
    super.dispose();
  }

  /// ------------------ Smart Summarizer ------------------
  void _generateSummary() {
    String text = _summarizerController.text.trim();
    if (text.isEmpty) return;

    List<String> sentences = text.split(RegExp(r'[.!?]'));
    final stopWords = {
      'the', 'is', 'a', 'an', 'and', 'or', 'in', 'on', 'of', 'to', 'for', 'with', 'by', 'as', 'at'
    };

    Map<String, int> wordFreq = {};
    for (var sentence in sentences) {
      for (var word in sentence.toLowerCase().split(' ')) {
        String cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
        if (cleanWord.isEmpty || stopWords.contains(cleanWord)) continue;
        wordFreq[cleanWord] = (wordFreq[cleanWord] ?? 0) + 1;
      }
    }

    Map<String, int> sentenceScores = {};
    for (var sentence in sentences) {
      int score = 0;
      for (var word in sentence.toLowerCase().split(' ')) {
        String cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
        score += wordFreq[cleanWord] ?? 0;
      }
      sentenceScores[sentence] = score;
    }

    var topSentences = sentenceScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<String> summarySentences =
    topSentences.take(3).map((e) => e.key.trim()).toList();

    List<TextSpan> spans = [];
    for (var sentence in summarySentences) {
      List<String> words = sentence.split(' ');
      for (var word in words) {
        String cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        bool isKeyword = wordFreq.containsKey(cleanWord) && !stopWords.contains(cleanWord);
        spans.add(TextSpan(
            text: '$word ',
            style: TextStyle(
                fontWeight: isKeyword ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87)));
      }
      spans.add(const TextSpan(text: '. '));
    }

    setState(() {
      _summarySpans = spans;
    });
  }

  /// ------------------ Text to Speech ------------------
  void _playTTS() async {
    String text = _ttsController.text.trim();
    if (text.isEmpty) return;

    await _flutterTts.setSpeechRate(0.7); // slow & clear
    await _flutterTts.speak(text);
  }

  void _pauseTTS() async {
    await _flutterTts.pause();
  }

  void _stopTTS() async {
    await _flutterTts.stop();
  }

  /// ------------------ Smart Quiz Generator ------------------
  void _generateQuiz() {
    String text = _quizController.text.trim();
    if (text.isEmpty) return;

    List<String> sentences = text.split(RegExp(r'[.!?]')).where((s) => s.trim().isNotEmpty).toList();
    sentences.shuffle();

    // Generate 3 questions
    List<QuizQuestion> quiz = [];
    int count = min(3, sentences.length);
    for (int i = 0; i < count; i++) {
      String correctAnswer = sentences[i].trim();
      List<String> options = [correctAnswer];

      // Add 3 random wrong options
      for (int j = 0; j < 3; j++) {
        String wrong = sentences[(i + j + 1) % sentences.length].trim();
        options.add(wrong);
      }
      options.shuffle();

      quiz.add(QuizQuestion(question: "Question ${i + 1}", options: options, answer: correctAnswer));
    }

    setState(() {
      _questions = quiz;
      _userAnswers = {};
    });
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] != null &&
          _questions[i].options[_userAnswers[i]!] == _questions[i].answer) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text("AI Features"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: "AI Summarizer"),
            Tab(icon: Icon(Icons.volume_up), text: "Text to Speech"),
            Tab(icon: Icon(Icons.quiz), text: "Smart Quiz"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _aiSummarizerUI(),
          _textToSpeechUI(),
          _smartQuizUI(),
        ],
      ),
    );
  }

  /// ---------------- AI SUMMARIZER UI ----------------
  Widget _aiSummarizerUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Input Text", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _summarizerController,
              maxLines: null,
              decoration: const InputDecoration(
                  hintText: "Enter your text here...\n(e.g. notes, chapters, articles)",
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Summary Output", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: _summarySpans.isEmpty
                    ? const Text("Your summary will appear here...", style: TextStyle(color: Colors.grey))
                    : RichText(text: TextSpan(children: _summarySpans)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _generateSummary,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text("Generate Summary"),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- TEXT TO SPEECH UI ----------------
  Widget _textToSpeechUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Text to Convert", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _ttsController,
              maxLines: null,
              decoration: const InputDecoration(
                  hintText: "Enter text you want to hear...\n(e.g. study notes)", border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: const [Icon(Icons.speed), SizedBox(width: 8), Text("Speech Speed: 0.7x (slow & clear)")]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                  onPressed: _playTTS,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
              ElevatedButton.icon(
                  onPressed: _pauseTTS,
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
              ElevatedButton.icon(
                  onPressed: _stopTTS,
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- SMART QUIZ UI ----------------
  Widget _smartQuizUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Enter Text for Quiz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _quizController,
            maxLines: null,
            decoration: const InputDecoration(
                hintText: "Enter notes or chapters to generate quiz...",
                border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _generateQuiz,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E57C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text("Generate Quiz"),
          ),
        ),
        const SizedBox(height: 16),
        _questions.isEmpty
            ? const Text("Quiz will appear here after generation...", style: TextStyle(color: Colors.grey))
            : Expanded(
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              QuizQuestion q = _questions[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(q.options.length, (i) {
                        return RadioListTile<int>(
                          value: i,
                          groupValue: _userAnswers[index],
                          title: Text(q.options[i]),
                          onChanged: (val) {
                            setState(() {
                              _userAnswers[index] = val!;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_questions.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                int score = _calculateScore();
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Quiz Result"),
                      content: Text("You scored $score / ${_questions.length}"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context), child: const Text("OK"))
                      ],
                    ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text("Submit Quiz"),
            ),
          ),
      ]),
    );
  }
}

/// ---------------- QUIZ QUESTION MODEL ----------------
class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  QuizQuestion({required this.question, required this.options, required this.answer});
}
