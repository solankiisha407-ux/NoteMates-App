import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notemates/screens/view_notes_screen.dart';
import 'view_question_papers_screen.dart';
import 'ai_features_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        elevation: 0,
        title: const Text("Welcome Back"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          /// NOTES
          bigCard(
            context: context,
            icon: Icons.menu_book,
            title: "Notes",
            subtitle: "Access & download notes",
            buttonText: "View Notes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ViewNotesScreen(),
                ),
              );
            },
          ),

          /// QUESTION PAPERS
          bigCard(
            context: context,
            icon: Icons.assignment,
            title: "Question Papers",
            subtitle: "Previous year question papers",
            buttonText: "View Papers",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ViewQuestionPapersScreen(),
                ),
              );
            },
          ),

          /// AI FEATURES ✅ FIXED
          bigCard(
            context: context,
            icon: Icons.auto_awesome,
            title: "AI Features",
            subtitle: "Smart learning tools",
            buttonText: "Explore AI tools",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIFeaturesScreen(),
                ),
              );
            },
          ),

          /// PROFILE (disabled)
          bigCard(
            context: context,
            icon: Icons.person,
            title: "Profile",
            subtitle: "Manage your account",
            buttonText: "Coming Soon",
            enabled: false,
          ),
        ],
      ),
    );
  }

  /// 🔹 BIG CARD
  Widget bigCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFD1C4E9),
            child: Icon(
              icon,
              size: 30,
              color: const Color(0xFF4A148C),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled
                    ? const Color(0xFF7E57C2)
                    : Colors.grey.shade300,
                foregroundColor:
                enabled ? Colors.white : Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
