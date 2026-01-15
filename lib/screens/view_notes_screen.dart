import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewNotesScreen extends StatelessWidget {
  final String course;

  const ViewNotesScreen({super.key, required this.course});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("$course Notes"),
        backgroundColor: const Color(0xFF7E57C2),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .where("course", isEqualTo: course)
            .orderBy("uploaded_at", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7E57C2)));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No notes uploaded yet 😅",
                style: TextStyle(color: Color(0xFF4A148C), fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final note = docs[i].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => _openFile(note["file_url"]),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7E57C2), Color(0xFFD1C4E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        note["title"] ?? "Untitled",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: note["isPaid"] == true
                              ? Colors.redAccent
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note["isPaid"] == true
                              ? "Paid ₹${note["price"]}"
                              : "Free",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
