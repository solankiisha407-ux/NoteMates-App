import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/upload_notes_screen.dart'; // 👈 MUST ADD THIS IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),

      home: const LoginScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/upload': (context) => const UploadNotesScreen(),
      },
    );
  }
}
