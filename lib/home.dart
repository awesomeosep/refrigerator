import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<XFile>? _mediaFileList;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;

  String? _retrieveDataError;

  // bool addGridLinesPopupShowing = false;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController gridRowsController = TextEditingController();
  final TextEditingController gridColumnsController = TextEditingController();


  // void addGridLines () {

  // }

  Future<void> showGridLinesPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Grid Lines'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Add grid lines to the image'),
                const SizedBox(height: 16.0),
                Expanded(
                  child: Wrap(spacing: 8.0, runSpacing: 8.0, direction: Axis.horizontal, children: [
                    TextField(
                      controller: gridRowsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '# Rows',
                      ),
                    ),
                    TextField(
                      controller: gridColumnsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '# Columns',
                      ),
                    ),
                  ]),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update grid lines'),
              onPressed: () {
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
          _setImageFileListFromFile(pickedFile);
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
    if (_mediaFileList != null) {
      return ListView.builder(
        key: UniqueKey(),
        itemBuilder: (BuildContext context, int index) {
          return InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20.0), // Margin around the content
              minScale: 0.5, // Minimum scale (zoom out)
              maxScale: 4.0, //
              child: kIsWeb
                  ? Image.network(_mediaFileList![index].path)
                  : Image.file(
                      File(_mediaFileList![index].path),
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return const Center(child: Text('This image type is not supported'));
                      },
                    ));
        },
        itemCount: _mediaFileList!.length,
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
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files;
        }
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
        title: const Text("Upload image", style: TextStyle(color: Colors.white)),
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
          if (_mediaFileList != null)
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
