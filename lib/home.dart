import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drawing_app/utils/file_directories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Future<String> get _localPath async {
//   final directory = await getApplicationDocumentsDirectory();
//   return directory.path;
// }

class _HomePageState extends State<HomePage> {
  List<FileSystemEntity> files = [];

  firstLoad() async {
    await checkForSavedImagesFolder();
    String imagesDirectoryPath = await getImagesDirectory;
    final dir = Directory(imagesDirectoryPath);
    final List<FileSystemEntity> entities = await dir.list().toList();
    setState(() {
      files = entities;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstLoad();
    });
  }

  Future<void> checkForSavedImagesFolder() async {
    String imagesDirectoryPath = await getImagesDirectory;
    bool checkPathExistence = await Directory(imagesDirectoryPath).exists();
    if (!checkPathExistence) {
      print("creating new directory");
      await Directory(imagesDirectoryPath).create(recursive: true);
      print("should have created new directory");
    } else {
      print("directory already exists");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: const Text("Home", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FilledButton.icon(
              icon: const Icon(Icons.upload),
              onPressed: () async {
                await checkForSavedImagesFolder();
                Navigator.pushNamed(context, "/edit");
              },
              label: const Text("Upload Image")),
          const SizedBox(height: 16),
          if (files.isNotEmpty)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: files.map((item) => SizedBox(height: 150, child: Image.file(File(item.path)))).toList(),
            ),
        ]),
      ),
    );
  }
}
