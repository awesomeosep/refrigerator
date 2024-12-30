import 'dart:io';
import 'dart:math';

import 'package:drawing_app/edit.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:drawing_app/utils/get_image_dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  XFile? selectedFile;
  Size? selectedFileSize;
  Uint8List? selectedFileData;

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void setSelectedFileVars(XFile? file) async {
    Size? dimensions;
    Uint8List? data;
    if (file != null) {
      dimensions = await getImageDimensions(File(file.path));
      data = await file.readAsBytes();
    } else {
      dimensions = null;
      data = null;
    }
    setState(() {
      selectedFile = file;
      selectedFileSize = dimensions;
      selectedFileData = data;
    });
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
      return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: kIsWeb
              ? Image.network(fit: BoxFit.contain, selectedFile!.path)
              : Image.file(
                  File(selectedFile!.path),
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const Center(child: Text('This image type is not supported'));
                  },
                ));
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.indigo[400],
        title: const Text("Upload Image", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !kIsWeb && defaultTargetPlatform == TargetPlatform.android
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
                if (selectedFile == null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextButton.icon(
                          onPressed: () {
                            _onImageButtonPressed(ImageSource.gallery, context: context);
                          },
                          label: const Text("Pick image from gallery"),
                          icon: const Icon(Icons.photo)),
                      const SizedBox(
                        height: 16,
                      ),
                      if (_picker.supportsImageSource(ImageSource.camera))
                        TextButton.icon(
                            onPressed: () {
                              _onImageButtonPressed(ImageSource.camera, context: context);
                            },
                            label: const Text("Take picture"),
                            icon: const Icon(Icons.camera_alt))
                    ],
                  )
                else
                  Column(children: [
                    const SizedBox(height: 32),
                    Text("Name: ${selectedFile!.name}"),
                    Text("Size: ${selectedFileSize!.width} x ${selectedFileSize!.height}"),
                    Text("Aspect Ratio: ${selectedFileSize!.aspectRatio.toStringAsFixed(2)}"),
                    const SizedBox(height: 16),
                    Wrap(direction: Axis.horizontal, spacing: 8, runSpacing: 8, children: [
                      ElevatedButton.icon(
                          label: const Text("Pick another image"),
                          onPressed: () {
                            setState(() {
                              setSelectedFileVars(null);
                            });
                          },
                          icon: const Icon(Icons.arrow_back)),
                      FilledButton(
                          onPressed: () async {
                            String newImagePath = await saveImage(selectedFile!,
                                Random().nextInt(10000000).toString(), p.extension(selectedFile!.path));
                            Navigator.pushReplacementNamed(
                              context,
                              "/edit",
                              arguments: EditPageArguments(newImagePath),
                            );
                          },
                          child: const Text("Use this image"))
                    ])
                  ])
              ]),
        ),
      ),
    );
  }
}
