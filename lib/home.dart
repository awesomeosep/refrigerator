import 'dart:async';

import 'package:drawing_app/grid_over_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? selectedFile;
  Size? selectedFileSize;

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  int gridRows = 8;
  int gridColumns = 12;

  TextEditingController gridRowsController = TextEditingController(text: "8");
  TextEditingController gridColumnsController = TextEditingController(text: "12");

  void setSelectedFileVars(XFile? file) async {
    // Size? dimensions;
    // if (file != null) {
    //   dimensions = await getImageDimensions(File(file.path));
    // } else {
    //   dimensions = null;
    // }
    setState(() {
      selectedFile = file;
      // selectedFileSize = dimensions;
    });
    // print(selectedFileSize?.width);
    // print(selectedFileSize?.height);
  }

  Future<void> showGridLinesPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Grid Lines'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Add grid lines to the image'),
                const SizedBox(height: 16.0),
                Wrap(spacing: 8.0, runSpacing: 8.0, direction: Axis.horizontal, children: [
                  TextField(
                    controller: gridRowsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      labelText: '# Rows',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: gridColumnsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      labelText: '# Columns',
                    ),
                  ),
                ])
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                int rowsParsed = int.tryParse(gridRowsController.text) ?? 1;
                int columnsParsed = int.tryParse(gridColumnsController.text) ?? 1;
                if (rowsParsed < 1) {
                  rowsParsed = 1;
                }
                if (columnsParsed < 1) {
                  columnsParsed = 1;
                }
                setState(() {
                  gridRows = rowsParsed;
                  gridColumns = columnsParsed;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
        );
        setState(() {
          setSelectedFileVars(pickedFile);
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (selectedFile != null) {
      return InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0), // Margin around the content
        minScale: 0.5, // Minimum scale (zoom out)
        maxScale: 4.0, //
        child: GridOverImage(
          image: selectedFile!,
          // width: selectedFileSize!.width,
          // height: selectedFileSize!.height, // Replace with your image path
          rows: gridRows,
          columns: gridColumns,
          gridColor: Colors.red,
          gridLineWidth: 1,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        setSelectedFileVars(response.files?[0]);
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: const Text("Edit image", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _previewImages();
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _previewImages(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (selectedFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    showGridLinesPopup();
                  });
                },
                heroTag: 'grid0',
                tooltip: 'Add Grid Lines',
                child: const Icon(Icons.grid_3x3),
              ),
            ),
          FloatingActionButton(
            onPressed: () {
              _onImageButtonPressed(ImageSource.gallery, context: context);
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo),
          ),
          if (_picker.supportsImageSource(ImageSource.camera))
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  _onImageButtonPressed(ImageSource.camera, context: context);
                },
                heroTag: 'image2',
                tooltip: 'Take a Photo',
                child: const Icon(Icons.camera_alt),
              ),
            ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
