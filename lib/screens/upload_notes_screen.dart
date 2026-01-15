import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/dropbox_service.dart';

class UploadNotesScreen extends StatefulWidget {
  const UploadNotesScreen({super.key});

  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState();
}

class _UploadNotesScreenState extends State<UploadNotesScreen> {
  PlatformFile? _pickedFile;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? selectedCourse;
  bool isPaid = false;
  bool _isUploading = false;

  // 📂 Pick File
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.single;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking file: $e")));
    }
  }

  // ☁️ Upload to Dropbox + Save to Firestore
  Future<void> uploadFile() async {
    if (_pickedFile == null ||
        _titleController.text.isEmpty ||
        selectedCourse == null ||
        _subjectController.text.isEmpty ||
        (isPaid && _priceController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not logged in";

      final file = File(_pickedFile!.path!);
      final fileName =
          "${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}";

      // 🔥 UPLOAD FILE TO DROPBOX
      final dropboxUrl =
      await DropboxService.uploadFile(
        file: file,
        fileName: fileName,
      );

      if (dropboxUrl == null) {
        throw "Dropbox upload failed";
      }

      // 🔥 SAVE DATA TO FIRESTORE
      await FirebaseFirestore.instance.collection("notes").add({
        "title": _titleController.text.trim(),
        "course": selectedCourse,
        "subject": _subjectController.text.trim(),
        "isPaid": isPaid,
        "price": isPaid
            ? int.tryParse(_priceController.text.trim()) ?? 0
            : 0,
        "file_url": dropboxUrl,
        "uploaded_by": user.email,
        "uploaded_at": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploaded Successfully 🎉")),
      );

      setState(() {
        _pickedFile = null;
        _titleController.clear();
        _subjectController.clear();
        _priceController.clear();
        selectedCourse = null;
        isPaid = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text(
          "Upload Notes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: _inputDecoration("Enter Notes Title"),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedCourse,
                decoration: _inputDecoration("Select Course"),
                items: ["BSc IT", "BSc CS", "BAF"]
                    .map(
                      (course) => DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCourse = value);
                },
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _subjectController,
                decoration: _inputDecoration("Enter Subject Name"),
              ),

              const SizedBox(height: 15),

              SwitchListTile(
                title: const Text("Paid Notes?"),
                activeColor: const Color(0xFF7E57C2),
                value: isPaid,
                onChanged: (value) {
                  setState(() => isPaid = value);
                },
              ),

              if (isPaid)
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Enter Price (₹)"),
                ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: pickFile,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(color: const Color(0xFF7E57C2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _pickedFile == null
                          ? "Tap to select PDF / Image"
                          : "Selected: ${_pickedFile!.name}",
                      style: const TextStyle(
                          color: Color(0xFF4A148C)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: _isUploading ? null : uploadFile,
                icon: const Icon(Icons.cloud_upload,
                    color: Colors.white),
                label: _isUploading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
