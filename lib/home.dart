import 'dart:async';
import 'dart:io';

import 'package:drawing_app/get_image_dimensions.dart';
import 'package:drawing_app/grid_over_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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

  bool showGrid = false;
  int gridRows = 8;
  int gridColumns = 12;
  double gridLineWidth = 1;
  Color gridLineColor = Colors.red;
  Color popupCurrentColor = Colors.red;

  TextEditingController gridRowsController = TextEditingController(text: "8");
  TextEditingController gridColumnsController = TextEditingController(text: "12");
  TextEditingController gridLineWidthController = TextEditingController(text: "1");

  void setSelectedFileVars(XFile? file) async {
    Size? dimensions;
    if (file != null) {
      dimensions = await getImageDimensions(File(file.path));
    } else {
      dimensions = null;
    }
    setState(() {
      selectedFile = file;
      selectedFileSize = dimensions;
    });
    // print(selectedFileSize?.width);
    // print(selectedFileSize?.height);
  }

  Future<void> showGridLinesPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        Color popupCurrentColor2 = gridLineColor;

        return AlertDialog(
          // title: const Text('Grid Lines'),
          content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Wrap(spacing: 8.0, runSpacing: 8.0, direction: Axis.horizontal, children: [
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      title: const Text('Show grid'),
                      value: showGrid,
                      onChanged: (bool? value) {
                        setState(() {
                          showGrid = !showGrid;
                        });
                      },
                    ),
                    if (showGrid)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: gridRowsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: '# Rows',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: gridColumnsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: '# Columns',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: gridLineWidthController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Line Thickness',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Stack(children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: ExactAssetImage('assets/checkered_transparent_2.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: popupCurrentColor2,
                                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                                      ),
                                    ),
                                  ])),
                              const SizedBox(width: 8),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Choose a color'),
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                                pickerColor: popupCurrentColor2,
                                                onColorChanged: (color) {
                                                  setState(() {
                                                    popupCurrentColor2 = color;
                                                    // print(popupCurrentColor2);
                                                  });
                                                }),
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: const Text('Save'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text("Change line color"))
                            ],
                          ),
                        ],
                      )
                  ])
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                int rowsParsed = int.tryParse(gridRowsController.text) ?? 1;
                int columnsParsed = int.tryParse(gridColumnsController.text) ?? 1;
                double lineWidthParsed = double.tryParse(gridLineWidthController.text) ?? 1;
                if (rowsParsed < 1) {
                  rowsParsed = 1;
                }
                if (columnsParsed < 1) {
                  columnsParsed = 1;
                }
                if (lineWidthParsed <= 0) {
                  lineWidthParsed = 0.1;
                }
                setState(() {
                  gridRows = rowsParsed;
                  gridColumns = columnsParsed;
                  gridLineWidth = lineWidthParsed;
                  gridLineColor = popupCurrentColor2;
                });
                // print(gridLineColor);
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
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(24.0), // Margin around the content
        minScale: 0.1, // Minimum scale (zoom out)
        maxScale: 5.0, //
        child: GridOverImage(
          image: selectedFile!,
          gridOptions: GridOptions(
              originalSize: selectedFileSize!,
              rows: gridRows,
              columns: gridColumns,
              gridColor: gridLineColor,
              gridLineWidth: gridLineWidth,
              gridShowing: showGrid),
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
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Center(
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
