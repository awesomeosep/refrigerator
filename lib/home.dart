import 'dart:io';

import 'package:drawing_app/edit_popups/delete_file.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawing_app/edit.dart';

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
    final List<FileSystemEntity> entities = await getAllSavedImages();
    setState(() {
      files = entities;
    });
    print(files.length);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: const Text("Home", style: TextStyle(color: Colors.white)),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Upload New Image", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 16),
              FilledButton.icon(
                  icon: const Icon(Icons.upload),
                  onPressed: () async {
                    await checkForSavedImagesFolder();
                    Navigator.pushNamed(context, "/upload").whenComplete(firstLoad);
                  },
                  label: const Text("Upload Image")),
              const SizedBox(height: 16),
              const Text("Previous Images", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 16.0),
              if (files.isNotEmpty)
                Wrap(
                    direction: Axis.vertical,
                    spacing: 8,
                    children: files
                        .map((item) => Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SizedBox(height: 28, width: 28, child: Image.file(File(item.path))),
                                Text(XFile(item.path).name),
                                IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/edit", arguments: EditPageArguments(item.path));
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      showDeleteImagePopup(context, item.path).then((e) {
                                        firstLoad();
                                      });
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ))
                        .toList())
              // Wrap(
              //   spacing: 32,
              //   runSpacing: 32,
              //   children: files.map((item) => SizedBox(height: 150, child: Image.file(File(item.path)))).toList(),
              // )
              else
                const Text("You have not uploaded and edited any images yet"),
            ]),
          ),
        ),
      ),
    );
  }
}
