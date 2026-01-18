import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadNotesScreen extends StatefulWidget {
  UploadNotesScreen({super.key}); // ❌ NOT const

  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState();
}

class _UploadNotesScreenState extends State<UploadNotesScreen> {
  PlatformFile? pickedFile;

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final priceController = TextEditingController();

  bool isPaid = false;
  bool uploading = false;

  String selectedCourse = "BSc IT";

  final List<String> courses = [
    "BSc IT",
    "BCA",
    "BCom",
    "Engineering",
    "Other",
  ];

  /// PICK PDF FILE
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  /// UPLOAD NOTES
  Future<void> uploadNotes() async {
    if (pickedFile == null ||
        titleController.text.isEmpty ||
        subjectController.text.isEmpty ||
        (isPaid && priceController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    setState(() => uploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not logged in";

      await FirebaseFirestore.instance.collection("notes").add({
        "title": titleController.text.trim(),
        "subject": subjectController.text.trim(),
        "course": selectedCourse,
        "isPaid": isPaid,
        "price": isPaid ? int.parse(priceController.text) : 0,
        "file_url": "TEMP_URL", // connect storage later
        "uploaded_by": user.email,
        "uploadedAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notes Uploaded Successfully ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text("Upload Notes"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Notes Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// SUBJECT
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// COURSE DROPDOWN
            DropdownButtonFormField<String>(
              value: selectedCourse,
              items: courses
                  .map(
                    (course) => DropdownMenuItem(
                  value: course,
                  child: Text(course),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourse = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Course",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// PAID / FREE SWITCH
            SwitchListTile(
              title: const Text("Paid Notes"),
              subtitle: const Text("Enable if notes are paid"),
              value: isPaid,
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() {
                  isPaid = value;
                });
              },
            ),

            /// PRICE FIELD (ONLY IF PAID)
            if (isPaid) ...[
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (₹)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            /// FILE PICKER
            GestureDetector(
              onTap: pickFile,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    pickedFile == null
                        ? "Tap to select PDF"
                        : pickedFile!.name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: uploading ? null : uploadNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: uploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Upload Notes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
