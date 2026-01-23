import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadNotesScreen extends StatefulWidget {
  const UploadNotesScreen({super.key});

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

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    priceController.dispose();
    super.dispose();
  }

  /// 📄 PICK PDF
  Future<void> pickFile() async {
    FocusScope.of(context).unfocus(); // ✅ keyboard close

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && mounted) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  /// ⬆️ UPLOAD NOTES
  Future<void> uploadNotes() async {
    FocusScope.of(context).unfocus(); // ✅ important

    if (pickedFile == null ||
        titleController.text.trim().isEmpty ||
        subjectController.text.trim().isEmpty ||
        (isPaid && priceController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login again")),
      );
      return;
    }

    setState(() => uploading = true);

    try {
      await FirebaseFirestore.instance.collection("notes").add({
        "title": titleController.text.trim(),
        "subject": subjectController.text.trim(),
        "course": selectedCourse,
        "isPaid": isPaid,
        "price": isPaid ? int.parse(priceController.text.trim()) : 0,

        // ⚠️ TEMP LINK (REAL LINK BAAD ME)
        "file_url": "https://example.com",

        "uploaded_by": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notes Uploaded Successfully ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => uploading = false);
      }
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // ✅ tap outside
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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

              /// COURSE
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

              const SizedBox(height: 12),

              /// PAID SWITCH
              SwitchListTile(
                title: const Text("Paid Notes"),
                value: isPaid,
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  setState(() {
                    isPaid = value;
                  });
                },
              ),

              if (isPaid)
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price (₹)",
                    border: OutlineInputBorder(),
                  ),
                ),

              const SizedBox(height: 20),

              /// FILE PICK
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
                      : const Text("Upload Notes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
