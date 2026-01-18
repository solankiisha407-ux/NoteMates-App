import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notemates/screens/view_notes_screen.dart';
import 'view_question_papers_screen.dart';

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
            icon: Icons.menu_book,
            title: "Notes",
            subtitle: "Access & download notes",
            buttonText: "View Notes",
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewNotesScreen(),
                ),
              );
            },
          ),

          /// QUESTION PAPERS
          bigCard(
            icon: Icons.assignment,
            title: "Question Papers",
            subtitle: "Previous year question papers",
            buttonText: "View Papers",
            enabled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ViewQuestionPapersScreen(),
                ),
              );
            },
          ),

          /// AI FEATURES
          bigCard(
            icon: Icons.auto_awesome,
            title: "AI Features",
            subtitle: "Smart learning tools",
            buttonText: "Coming Soon",
            enabled: false,
          ),

          const SizedBox(height: 24),

          /// PROFILE
          bigCard(
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

  /// 🔹 BIG CARD WIDGET
  Widget bigCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool enabled,
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
          /// ICON
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

          /// TITLE
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          /// SUBTITLE
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          /// BUTTON
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
