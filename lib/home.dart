import 'dart:io';

import 'package:drawing_app/edit_popups/delete_file.dart';
import 'package:drawing_app/utils/bottom_nav_bar.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawing_app/edit.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:deepcopy/deepcopy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FileSystemEntity> files = [];
  List<ImageData> fileData = [];
  String sortBy = "File name";
  int sortDirection = 1;
  List filesSorted = [];
  bool loadingFiles = false;
  bool hideFiles = false;

  void firstLoad([bool showLoading = true]) async {
    if (showLoading) {
      setState(() {
        loadingFiles = true;
      });
    }
    setState(() {
      hideFiles = true;
    });
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
    sortFiles();
    setState(() {
      loadingFiles = false;
      hideFiles = false;
    });
  }

  void sortFiles() {
    setState(() {
      filesSorted = files.deepcopy();
    });
    if (fileData.isNotEmpty && files.isNotEmpty) {
      if (sortBy == "File name") {
        setState(() {
          filesSorted.sort((a, b) =>
              fileData[files.indexOf(a)].name.toLowerCase().compareTo(fileData[files.indexOf(b)].name.toLowerCase()) *
              sortDirection);
        });
      } else if (sortBy == "Date modified") {
        setState(() {
          filesSorted.sort((a, b) =>
              fileData[files.indexOf(a)].lastModified.compareTo(fileData[files.indexOf(b)].lastModified) *
              sortDirection *
              -1);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstLoad();
    });
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: const MyBottomNavBar(page: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        clipBehavior: Clip.none,
        title: SearchAnchor.bar(
          barHintText: "Search references",
          barElevation: const WidgetStatePropertyAll(2),
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            // Implement your search suggestions here
            return List<ListTile>.generate(files.where((item) => fileData[files.indexOf(item)].name.toLowerCase().contains(controller.text.toLowerCase())).length, (int index) {
              final itemFile = files.where((item) => fileData[files.indexOf(item)].name.toLowerCase().contains(controller.text.toLowerCase())).elementAt(index);
              final itemData = fileData[files.indexOf(itemFile)];
              return ListTile(
                title: Text(itemData.name),
                subtitle: Text(DateFormat.yMMMd().format(itemData.lastModified)),
                onTap: () {
                  Navigator.pushNamed(context, "/edit",
                          arguments: EditPageArguments(
                              itemData.id, itemFile.path, ""))
                      .whenComplete(firstLoad);
                },
              );
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await checkForSavedImagesFolder();
            if (context.mounted) {
              Navigator.pushNamed(context, "/upload").whenComplete(firstLoad);
            }
          }),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              firstLoad(false);
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    const Text("Sort by: "),
                    const SizedBox(width: 4),
                    DropdownMenu<String>(
                      initialSelection: "File name",
                      onSelected: (String? value) {
                        setState(() {
                          sortBy = value!;
                        });
                        sortFiles();
                      },
                      dropdownMenuEntries: ["File name", "Date modified"]
                          .map<DropdownMenuEntry<String>>((String name) => DropdownMenuEntry(value: name, label: name))
                          .toList(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            sortDirection = -sortDirection;
                          });
                          sortFiles();
                        },
                        icon: Transform.flip(flipY: sortDirection < 0, child: const Icon(Icons.arrow_downward)))
                  ]),
                  const SizedBox(
                    height: 16,
                  ),
                  if (hideFiles)
                    const SizedBox.shrink()
                  else if (loadingFiles)
                    Center(
                      child: Column(
                        children: [CircularProgressIndicator(color: colorScheme.primary)],
                      ),
                    )
                  else if (files.isNotEmpty && fileData.length == files.length)
                    StaggeredGrid.count(
                      crossAxisCount:
                          MediaQuery.sizeOf(context).width > 300 ? (MediaQuery.sizeOf(context).width / 150).floor() : 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: List.generate(filesSorted.length, (index) {
                        return Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              side: BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                SizedBox(width: double.maxFinite, child: Image.file(File(filesSorted[index].path))),
                                // const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Wrap(direction: Axis.horizontal, spacing: 4, runSpacing: 4, children: [
                                      Text(fileData[files.indexOf(filesSorted[index])].name),
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(fileData[files.indexOf(filesSorted[index])].lastModified),
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ]),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton.filledTonal(
                                            iconSize: 20,
                                            onPressed: () {
                                              Navigator.pushNamed(context, "/edit",
                                                      arguments: EditPageArguments(
                                                          fileData[files.indexOf(filesSorted[index])].id,
                                                          filesSorted[index].path,
                                                          ""))
                                                  .whenComplete(firstLoad);
                                            },
                                            icon: const Icon(Icons.edit)),
                                        const SizedBox(width: 4),
                                        IconButton.filledTonal(
                                            iconSize: 20,
                                            onPressed: () {
                                              showDeleteImagePopup(
                                                      context,
                                                      fileData[files.indexOf(filesSorted[index])].id,
                                                      fileData[files.indexOf(filesSorted[index])].name,
                                                      p.extension(filesSorted[index].path))
                                                  .then((e) {
                                                firstLoad();
                                              });
                                            },
                                            icon: const Icon(Icons.delete)),
                                      ],
                                    )
                                  ]),
                                ),
                              ],
                            ));
                      }),
                    )
                  else
                    const Center(child: Text("You have not uploaded any references yet.", textAlign: TextAlign.center)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
