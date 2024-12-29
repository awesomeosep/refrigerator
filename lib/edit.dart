import 'dart:async';
import 'dart:io';
import 'dart:math';

// import 'package:crop_your_image/crop_your_image.dart';
// import 'package:croppy/croppy.dart';
import 'package:drawing_app/utils/default_color_filters.dart';
// import 'package:drawing_app/files.dart';
import 'package:drawing_app/utils/get_image_dimensions.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

class NamedColorFilter {
  final String name;
  final String id;
  final ColorFilter filter;

  NamedColorFilter({required this.name, required this.id, required this.filter});
}

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
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
  String? selectedFilter;

  TextEditingController gridRowsController = TextEditingController(text: "8");
  TextEditingController gridColumnsController = TextEditingController(text: "12");
  TextEditingController gridLineWidthController = TextEditingController(text: "1");
  TextEditingController fileNameController = TextEditingController(text: "Untitled");
  // TextEditingController fileNameController = TextEditingController(text: "Untitled");

  List<NamedColorFilter> defaultFilters = defaultColorFilters;

  Uint8List? selectedFileData;

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

  Future<void> showImageFiltersPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String? popupSelectedFilter = selectedFilter;

        return AlertDialog(
          content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                  children: defaultFilters
                      .map((item) => CheckboxListTile(
                            contentPadding: const EdgeInsets.all(0),
                            dense: true,
                            title: Text(item.name),
                            value: popupSelectedFilter == item.id,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  popupSelectedFilter = item.id;
                                } else {
                                  popupSelectedFilter = null;
                                }
                              });
                            },
                          ))
                      .toList()),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                setState(() {
                  selectedFilter = popupSelectedFilter;
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

  // Future<void> showCroppingPopup() async {
  //   final croppedBytes = await ImageCropping.cropImage(
  //     context: context,
  //     imageBytes: selectedFileData!,
  //     onImageStartLoading: () {
  //       // showLoader();
  //     },
  //     onImageEndLoading: () {
  //       // hideLoader();
  //     },
  //     onImageDoneListener: (data) {
  //       // You can also use a listener instead of awaiting the function
  //       setState(() {
  //         // imageBytes = data;
  //       });
  //     },
  //     selectedImageRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
  //     visibleOtherAspectRatios: true,
  //     squareBorderWidth: 2,
  //     squareCircleColor: Colors.black,
  //     defaultTextColor: Colors.orange,
  //     selectedTextColor: Colors.black,
  //     colorForWhiteSpace: Colors.grey,
  //     encodingQuality: 80,
  //     outputImageFormat: OutputImageFormat.jpg,
  //     // workerPath: 'crop_worker.js',
  //   );
  //   print(croppedBytes);
  //   setState(() {
  //     setSelectedFileVars(XFile.fromData(croppedBytes,
  //         name: "${Random().nextInt(1000000).toString()}.jpg", path: "${Random().nextInt(1000000).toString()}.jpg"));
  //   });

  //   // return showDialog<void>(
  //   //   context: context,
  //   //   barrierDismissible: false, // user must tap button!
  //   //   builder: (BuildContext context) {
  //   //     final _controller = CropController();

  //   //     return AlertDialog(
  //   //       title: const Text("hello"),
  //   //       content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //   //         return SizedBox(
  //   //           width: 600,
  //   //           height: 600,
  //   //           child: Crop(
  //   //               willUpdateScale: (newScale) => newScale < 5,
  //   //               cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
  //   //               interactive: true,
  //   //               // fixCropRect: true,
  //   //               radius: 20,
  //   //               initialRectBuilder: InitialRectBuilder.withBuilder(
  //   //                 (viewportRect, imageRect) {
  //   //                   return Rect.fromLTRB(
  //   //                     viewportRect.left + 24,
  //   //                     viewportRect.top + 24,
  //   //                     viewportRect.right - 24,
  //   //                     viewportRect.bottom - 24,
  //   //                   );
  //   //                 },
  //   //               ),
  //   //               image: selectedFileData!,
  //   //               controller: _controller,
  //   //               onCropped: (result) {
  //   //                 switch (result) {
  //   //                   case CropSuccess(:final croppedImage):
  //   //                     selectedFile = XFile.fromData(croppedImage);
  //   //                   case CropFailure(:final cause):
  //   //                     print(cause);
  //   //                 }
  //   //               }),
  //   //         );
  //   //       }),
  //   //       actions: [
  //   //         TextButton(
  //   //           child: const Text('Update'),
  //   //           onPressed: () {
  //   //             Navigator.of(context).pop();
  //   //           },
  //   //         )
  //   //       ],
  //   //     );
  //   //   },
  //   // );
  // }

  Future<void> showSavingPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save File'),
          content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  direction: Axis.horizontal,
                  children: [
                    TextField(
                      controller: fileNameController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'File Name',
                      ),
                    ),
                  ],
                )
              ]),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text('Save file'),
              onPressed: () async {
                String localPath = await _localPath;
                selectedFile!.saveTo(
                    "$localPath/_drawing_app_data/saved_images/${Random().nextInt(10000000).toString()}${p.extension(selectedFile!.path)}");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Saved image"),
                ));
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
        child: EditedImage(
            image: selectedFile!,
            gridOptions: GridOptions(
                originalSize: selectedFileSize!,
                rows: gridRows,
                columns: gridColumns,
                gridColor: gridLineColor,
                gridLineWidth: gridLineWidth,
                gridShowing: showGrid),
            filter: selectedFilter == null
                ? null
                : defaultFilters.firstWhere((item) {
                    return item.id == selectedFilter;
                  })),
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

  Future<Uint8List?> getImageData() async {
    if (selectedFile == null) {
      return null;
    } else {
      return await selectedFile!.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.indigo[400],
        title: const Text("Edit Image", style: TextStyle(color: Colors.white)),
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
      floatingActionButton: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showSavingPopup();
                    });
                  },
                  heroTag: 'save0',
                  tooltip: 'Save image & edits',
                  child: const Icon(Icons.save),
                ),
              ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      // showCroppingPopup();
                    });
                  },
                  heroTag: 'cropping0',
                  tooltip: 'Crop image',
                  child: const Icon(Icons.crop),
                ),
              ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showImageFiltersPopup();
                    });
                  },
                  heroTag: 'filters0',
                  tooltip: 'Apply color filters',
                  child: const Icon(Icons.filter),
                ),
              ),
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
