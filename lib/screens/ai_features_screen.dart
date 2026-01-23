import 'package:flutter/material.dart';

class AIFeaturesScreen extends StatefulWidget {
  const AIFeaturesScreen({super.key});

  @override
  State<AIFeaturesScreen> createState() => _AIFeaturesScreenState();
}

class _AIFeaturesScreenState extends State<AIFeaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _aiSummarizerUI(),
          _textToSpeechUI(),
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
          const Text(
            "Input Text",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Enter your text here...\n(e.g. notes, chapters, articles)",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Summary Output",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Your summary will appear here...",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E57C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
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
          const Text(
            "Text to Convert",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Enter text you want to hear...\n(e.g. study notes)",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Icon(Icons.speed),
              SizedBox(width: 8),
              Text("Speech Speed: 1x"),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text("Play"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E57C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
