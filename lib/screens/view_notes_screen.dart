import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 BACK
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 6),
                    Text("Back to Home"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🧾 TITLE
              const Text(
                "My Notes",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Browse and download study notes",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              /// 📚 NOTES FROM FIRESTORE
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notes")
                      .orderBy("uploadedAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No notes uploaded yet"),
                      );
                    }

                    final notes = snapshot.data!.docs;

                    return GridView.builder(
                      itemCount: notes.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final data =
                        notes[index].data() as Map<String, dynamic>;

                        return NotesCard(
                          title: data['title'] ?? '',
                          subject: data['subject'] ?? '',
                          description:
                          data['description'] ?? '',
                          uploaded:
                          _formatDate(data['uploadedAt']),
                          isPaid: data['isPaid'] ?? false,
                          price:
                          (data['price'] ?? 0).toDouble(),
                          fileUrl: data['file_url'] ?? '',
                        );
                      },
                    );
                  },
                ),
              ),

              /// ⬆️ UPLOAD SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.upload),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upload Your Notes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Share your study materials with others",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // TODO: navigate to UploadNotesScreen
                      },
                      child: const Text("Upload Notes"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 FORMAT DATE
  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}

/// 🧩 NOTES CARD
class NotesCard extends StatelessWidget {
  final String title;
  final String subject;
  final String description;
  final String uploaded;
  final bool isPaid;
  final double price;
  final String fileUrl;

  const NotesCard({
    super.key,
    required this.title,
    required this.subject,
    required this.description,
    required this.uploaded,
    required this.isPaid,
    required this.price,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE + BADGE
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.orange[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? "₹$price" : "FREE",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    isPaid ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// SUBJECT
          Text(
            subject,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          /// DESCRIPTION
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),

          const Spacer(),

          /// DATE
          Text(
            "Uploaded: $uploaded",
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
            ),
          ),

          const SizedBox(height: 10),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                isPaid ? Icons.lock : Icons.download,
                size: 16,
              ),
              label: Text(
                isPaid ? "Purchase" : "Download",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (isPaid) return;

                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
