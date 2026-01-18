import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/dropbox_service.dart';

class UploadQuestionPaperScreen extends StatefulWidget {
  const UploadQuestionPaperScreen({super.key});

  @override
  State<UploadQuestionPaperScreen> createState() =>
      _UploadQuestionPaperScreenState();
}

class _UploadQuestionPaperScreenState
    extends State<UploadQuestionPaperScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  bool loading = false;

  Future<void> uploadPaper() async {
    setState(() => loading = true);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      setState(() => loading = false);
      return;
    }

    final pickedFile = result.files.single;

    if (pickedFile.path == null) {
      setState(() => loading = false);
      return;
    }

    /// ✅ FIXED DROPBOX CALL (NO UI CHANGE)
    final downloadUrl = await DropboxService.uploadFile(
      file: File(pickedFile.path!),
      fileName: pickedFile.name,
    );

    if (downloadUrl == null) {
      setState(() => loading = false);
      return;
    }

    await FirebaseFirestore.instance.collection('question_papers').add({
      'title': titleController.text.trim(),
      'description': descController.text.trim(),
      'file_url': downloadUrl,
      'uploaded_at': Timestamp.now(),
    });

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Question paper uploaded successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text("Upload Question Paper"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Paper Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A148C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : uploadPaper,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Select File & Upload"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
