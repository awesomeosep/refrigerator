import 'dart:io';
import 'dart:math';

import 'package:drawing_app/edit.dart';
import 'package:drawing_app/utils/edited_image.dart';
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
      dimensions = await calculateImageDimension(File(file.path));
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
      return SizedBox(
        width: double.maxFinite,
        child: Center(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: kIsWeb
                    ? Image.network(fit: BoxFit.contain, selectedFile!.path)
                    : Image.file(
                        File(selectedFile!.path),
                        fit: BoxFit.contain,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Center(child: Text('This image type is not supported'));
                        },
                      )),
          ),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        "You have not picked an image yet.",
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
        backgroundColor: Colors.indigo[500],
        title: const Text("Upload Image", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  width: double.maxFinite,
                  child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                      ? FutureBuilder<void>(
                          future: retrieveLostData(),
                          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const Text(
                                  "You have not picked an image yet.",
                                  textAlign: TextAlign.center,
                                );
                              case ConnectionState.done:
                                return _previewImages();
                              case ConnectionState.active:
                                if (snapshot.hasError) {
                                  return Text(
                                    "Pick image error: ${snapshot.error}}",
                                    textAlign: TextAlign.center,
                                  );
                                } else {
                                  return const Text(
                                    "You have not picked an image yet.",
                                    textAlign: TextAlign.center,
                                  );
                                }
                            }
                          },
                        )
                      : _previewImages(),
                ),
                const SizedBox(height: 16),
                if (selectedFile == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      TextButton.icon(
                          onPressed: () {
                            _onImageButtonPressed(ImageSource.gallery, context: context);
                          },
                          label: const Text("Pick from gallery"),
                          icon: const Icon(Icons.photo)),
                      const SizedBox(
                        height: 8,
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
                  Center(
                    child: Column(children: [
                      ElevatedButton.icon(
                          label: const Text("Pick another image"),
                          onPressed: () {
                            setState(() {
                              setSelectedFileVars(null);
                            });
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const SizedBox(height: 16),
                      Text("Name: ${selectedFile!.name}", textAlign: TextAlign.center),
                      Text("Dimensions: ${selectedFileSize!.width} x ${selectedFileSize!.height}"),
                      Text("Aspect Ratio: ${selectedFileSize!.aspectRatio.toStringAsFixed(2)}"),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: () async {
                            String newFileId = Random().nextInt(10000000).toString();
                            String newImagePath =
                                await saveImage(selectedFile!, newFileId, p.extension(selectedFile!.path));
                            String savedDataPath = (await saveImageData(
                                    "Untitled",
                                    newFileId,
                                    ImageData(
                                      lastModified: DateTime.now(),
                                      cropRect: const Rect.fromLTRB(0, 0, 1, 1),
                                      name: "Untitled",
                                      id: newFileId,
                                      colorFilter: null,
                                      gridOptions: const GridOptions(
                                          originalSize: Size(0, 0),
                                          rows: 4,
                                          columns: 4,
                                          gridColor: Colors.red,
                                          gridLineWidth: 1.0,
                                          gridShowing: false),
                                    )))
                                .path;
                            if (context.mounted) {
                              Navigator.popAndPushNamed(
                                context,
                                "/edit",
                                arguments: EditPageArguments(newFileId, newImagePath, savedDataPath),
                              );
                            }
                          },
                          child: const Text("Use this image"))
                    ]),
                  )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
