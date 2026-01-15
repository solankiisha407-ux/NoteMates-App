import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_notes_screen.dart';
import 'upload_notes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("NoteMates"),
        backgroundColor: const Color(0xFF7E57C2),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            Text(
              user?.email ?? "User",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Search courses or notes...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A148C)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Courses 🎓",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A)),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                FirebaseFirestore.instance.collection("notes").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.docs;

                  final courses = notes
                      .map((doc) => doc["course"])
                      .where((c) => c != null)
                      .toSet()
                      .toList();

                  if (courses.isEmpty) {
                    return const Center(
                      child: Text(
                        "No courses yet 😕\nUpload notes to get started!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      String course = courses[index];
                      return courseCard(context, course);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UploadNotesScreen()));
        },
        backgroundColor: const Color(0xFF7E57C2),
        child: const Icon(Icons.cloud_upload, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget courseCard(BuildContext context, String course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewNotesScreen(course: course)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD1C4E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            course,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
        ),
      ),
    );
  }
}