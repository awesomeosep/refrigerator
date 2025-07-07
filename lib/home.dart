import 'dart:io';

import 'package:drawing_app/edit_popups/delete_file.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawing_app/edit.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FileSystemEntity> files = [];
  List<ImageData> fileData = [];

  firstLoad() async {
    await checkForSavedImagesFolder();
    final List<FileSystemEntity> entities = await getAllSavedImages();
    setState(() {
      files = entities;
    });
    List<ImageData> newFileData = [];
    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        ImageData thisFileData = await getSavedImageData(p.basenameWithoutExtension(XFile(files[i].path).name));
        newFileData.add(thisFileData);
      }
    }
    setState(() {
      fileData = newFileData;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
      floatingActionButton: FloatingActionButton.small(
          child: const Icon(Icons.upload),
          onPressed: () async {
            await checkForSavedImagesFolder();
            if (context.mounted) {
              Navigator.pushNamed(context, "/upload").whenComplete(firstLoad);
            }
          }),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Your Images", style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    IconButton(
                        onPressed: () {
                          firstLoad();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Refreshed"),
                          ));
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
                const SizedBox(height: 16.0),
                if (files.isNotEmpty && fileData.length == files.length)
                  Container(
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: List.generate(files.length, (index) {
                        return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                SizedBox(width: double.maxFinite, child: Image.file(File(files[index].path))),
                                const SizedBox(height: 8),
                                Text(fileData[files.indexOf(files[index])].name),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, "/edit",
                                                  arguments: EditPageArguments(
                                                      fileData[files.indexOf(files[index])].id, files[index].path, ""))
                                              .whenComplete(firstLoad);
                                        },
                                        icon: const Icon(Icons.edit)),
                                    const SizedBox(width: 4),
                                    IconButton(
                                        onPressed: () {
                                          showDeleteImagePopup(context, fileData[files.indexOf(files[index])].id, fileData[files.indexOf(files[index])].name,
                                                  p.extension(files[index].path))
                                              .then((e) {
                                            firstLoad();
                                          });
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                              ],
                            ));
                      }),
                    ),
                  )
                else
                  const Text("You have not uploaded and edited any images yet"),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
