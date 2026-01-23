import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_notes_screen.dart';

class ViewNotesScreen extends StatefulWidget {
  const ViewNotesScreen({super.key});

  @override
  State<ViewNotesScreen> createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  String searchText = '';
  String courseFilter = 'All';
  String priceFilter = 'All'; // ✅ Free / Paid

  final courses = ['All', 'BSc IT', 'BCA', 'BCom', 'Engineering', 'Other'];
  final priceFilters = ['All', 'Free', 'Paid'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🔍 SEARCH
              TextField(
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) =>
                    setState(() => searchText = v.toLowerCase()),
              ),

              const SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: courseFilter,
                items: courses
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => courseFilter = v!),
                decoration: const InputDecoration(
                  labelText: "Filter by Course",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),


              DropdownButtonFormField<String>(
                value: priceFilter,
                items: priceFilters
                    .map((p) =>
                    DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => priceFilter = v!),
                decoration: const InputDecoration(
                  labelText: "Filter by Price",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),


              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs.where((doc) {
                      final data =
                      doc.data() as Map<String, dynamic>;

                      final title =
                      (data['title'] ?? '').toString().toLowerCase();
                      final course = data['course'] ?? '';
                      final isPaid = data['isPaid'] ?? false;

                      final matchSearch =
                      title.contains(searchText);
                      final matchCourse = courseFilter == 'All' ||
                          course == courseFilter;
                      final matchPrice = priceFilter == 'All' ||
                          (priceFilter == 'Free' && !isPaid) ||
                          (priceFilter == 'Paid' && isPaid);

                      return matchSearch &&
                          matchCourse &&
                          matchPrice;
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                          child: Text("No notes found"));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data =
                        docs[i].data() as Map<String, dynamic>;
                        final isPaid = data['isPaid'] ?? false;

                        return Card(
                          margin:
                          const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['title'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(isPaid
                                          ? "₹${data['price']}"
                                          : "FREE"),
                                      backgroundColor: isPaid
                                          ? Colors.orange.shade200
                                          : Colors.green.shade200,
                                    ),
                                  ],
                                ),
                                Text(
                                  data['subject'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.deepPurple),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor: isPaid
                                          ? Colors.orange
                                          : const Color(0xFF7E57C2),
                                    ),
                                    onPressed: () async {
                                      if (isPaid) return;

                                      final url = Uri.parse(
                                          data['file_url']);
                                      await launchUrl(url,
                                          mode: LaunchMode
                                              .externalApplication);
                                    },
                                    child: Text(isPaid
                                        ? "Purchase"
                                        : "Download"),
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
              ),

              /// ⬆️ UPLOAD BUTTON (FIXED)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Notes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF7E57C2),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const UploadNotesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
