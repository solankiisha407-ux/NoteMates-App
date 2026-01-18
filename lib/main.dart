import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NoteMatesApp());
}

class NoteMatesApp extends StatelessWidget {
  const NoteMatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoteMates',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),

      // ❌ REMOVE routes — NOT NEEDED
      // routes: {
      //   '/upload': (context) => UploadNotesScreen(),
      // },
    );
  }
}
