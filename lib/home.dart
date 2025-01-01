import 'dart:io';

import 'package:drawing_app/edit_popups/delete_file.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawing_app/edit.dart';
import 'package:path/path.dart' as p;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FileSystemEntity> files = [];
  List<ImageData> fileData = [];
  // bool _dataLoaded = false;

  firstLoad() async {
    await checkForSavedImagesFolder();
    final List<FileSystemEntity> entities = await getAllSavedImages();
    setState(() {
      files = entities;
    });
    print(files.length);
    List<ImageData> newFileData = [];
    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        print(await File(files[i].path).exists());
        ImageData thisFileData = await getSavedImageData(p.basenameWithoutExtension(XFile(files[i].path).name));
        newFileData.add(thisFileData);
      }
    }
    print(newFileData.length);
    setState(() {
      fileData = newFileData;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   if (!_dataLoaded) {
  //     print("home init state");
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       firstLoad();
  //       _dataLoaded = true;
  //     });
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("home did change dependencies");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("hello home page");

    // if (context.read<ImageListChanged>().changed == true) {
    //   firstLoad();
    // }

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Previously Edited Images", style: TextStyle(fontSize: 22)),
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
                                Text(fileData[files.indexOf(item)].name),
                                IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/edit",
                                              arguments:
                                                  EditPageArguments(fileData[files.indexOf(item)].id, item.path, ""))
                                          .whenComplete(firstLoad);
                                      ;
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      showDeleteImagePopup(
                                              context, fileData[files.indexOf(item)].id, p.extension(item.path))
                                          .then((e) {
                                        firstLoad();
                                      });
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ))
                        .toList())
              else
                const Text("You have not uploaded and edited any images yet"),
            ]),
          ),
        ),
      ),
    );
  }
}
