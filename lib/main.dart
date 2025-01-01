import 'package:drawing_app/edit.dart';
import 'package:drawing_app/home.dart';
import 'package:drawing_app/upload.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.indigo[50]),
      title: 'Drawing App',
      routes: {
        "/": (context) => const HomePage(),
        "/home": (context) => const HomePage(),
        "/upload": (context) => const UploadPage(),
        "/edit": (context) => const EditPage(),
      },
    );
  }
}
