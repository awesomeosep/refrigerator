import 'dart:async';
import 'dart:io';
import 'dart:math';

// import 'package:crop_your_image/crop_your_image.dart';
// import 'package:croppy/croppy.dart';
import 'package:drawing_app/edit_popups/grid_lines.dart';
import 'package:drawing_app/edit_popups/image_filters.dart';
import 'package:drawing_app/edit_popups/save_image.dart';
import 'package:drawing_app/utils/default_color_filters.dart';
import 'package:drawing_app/utils/files.dart';
// import 'package:drawing_app/files.dart';
import 'package:drawing_app/utils/get_image_dimensions.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class NamedColorFilter {
  final String name;
  final String id;
  final ColorFilter filter;

  NamedColorFilter({required this.name, required this.id, required this.filter});
}

class EditPageArguments {
  final String fileId;
  final String filePath;
  final String dataPath;

  EditPageArguments(this.fileId, this.filePath, this.dataPath);
}

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  XFile? selectedFile;
  Size? selectedFileSize;
  String selectedFileName = "Untitled";

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
  bool saveACopy = false;

  // TextEditingController fileNameController = TextEditingController(text: "Untitled");

  List<NamedColorFilter> defaultFilters = defaultColorFilters;

  Uint8List? selectedFileData;

  bool firstTimeRan = false;

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

  void setImageDataVars(ImageData imageData) async {
    setState(() {
      showGrid = imageData.gridOptions.gridShowing;
      gridRows = imageData.gridOptions.rows;
      gridColumns = imageData.gridOptions.columns;
      gridLineWidth = imageData.gridOptions.gridLineWidth;
      gridLineColor = imageData.gridOptions.gridColor;
      popupCurrentColor = imageData.gridOptions.gridColor;
      selectedFilter = imageData.colorFilter;
      selectedFileName = imageData.name;
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
      return InteractiveViewer(
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(42.0), // Margin around the content
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

  firstLoad() async {
    if (ModalRoute.of(context)?.settings.arguments != null) {
      final args = ModalRoute.of(context)!.settings.arguments as EditPageArguments;
      print("got the file ${args.filePath}");
      ImageData loadedImageData = await getSavedImageData(args.fileId);
      setSelectedFileVars(XFile(args.filePath));
      setImageDataVars(loadedImageData);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!firstTimeRan) {
      print("init state ran");
      firstLoad();
      setState(() {
        firstTimeRan = true;
      });
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
        child: Center(child: _previewImages()),
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
                      showSavingPopup(context, selectedFileName, (saveACopy, fileName) async {
                        String newFileId;
                        String newFilePath;
                        if (saveACopy) {
                          newFileId = Random().nextInt(10000000).toString();
                          newFilePath = await saveImage(selectedFile!, newFileId, p.extension(selectedFile!.path));
                        } else {
                          newFileId = p.basenameWithoutExtension(selectedFile!.name);
                          newFilePath = selectedFile!.path;
                        }
                        String savedDataPath = (await saveImageData(
                                fileName,
                                newFileId,
                                ImageData(
                                  name: fileName,
                                  id: newFileId,
                                  colorFilter: selectedFilter,
                                  gridOptions: GridOptions(
                                      originalSize: selectedFileSize!,
                                      rows: gridRows,
                                      columns: gridColumns,
                                      gridColor: gridLineColor,
                                      gridLineWidth: gridLineWidth,
                                      gridShowing: showGrid),
                                )))
                            .path;
                        // context.read<ImageListChanged>().changed = false;
                        Navigator.of(context).pop();
                        if (saveACopy) {
                          Navigator.popAndPushNamed(context, "/edit",
                              arguments: EditPageArguments(newFileId, newFilePath, savedDataPath));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Saved copy of image"),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Saved image"),
                          ));
                        }
                      });
                    });
                  },
                  heroTag: 'save0',
                  tooltip: 'Save image & edits',
                  child: const Icon(Icons.save),
                ),
              ),
            // if (selectedFile != null)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 16.0),
            //     child: FloatingActionButton(
            //       onPressed: () {
            //         setState(() {
            //           // showCroppingPopup();
            //         });
            //       },
            //       heroTag: 'cropping0',
            //       tooltip: 'Crop image',
            //       child: const Icon(Icons.crop),
            //     ),
            //   ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showImageFiltersPopup(context, selectedFilter, (filter) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      });
                    });
                  },
                  heroTag: 'filters0',
                  tooltip: 'Apply color filters',
                  child: const Icon(Icons.palette),
                ),
              ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showGridLinesPopup(
                          context,
                          GridOptions(
                              originalSize: const Size(0, 0),
                              rows: gridRows,
                              columns: gridColumns,
                              gridColor: gridLineColor,
                              gridLineWidth: gridLineWidth,
                              gridShowing: showGrid), (rows, columns, lineWidth, color, gridShowing) {
                        setState(() {
                          gridRows = rows;
                          gridColumns = columns;
                          gridLineWidth = lineWidth;
                          gridLineColor = color;
                          showGrid = gridShowing;
                        });
                        print(gridRows);
                        print(showGrid);
                      });
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
