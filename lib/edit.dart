import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drawing_app/edit_popups/cropping.dart';
import 'package:drawing_app/edit_popups/export_image.dart';
import 'package:drawing_app/edit_popups/grid_lines.dart';
import 'package:drawing_app/edit_popups/image_filters.dart';
import 'package:drawing_app/edit_popups/save_image.dart';
import 'package:drawing_app/utils/default_color_filters.dart';
import 'package:drawing_app/utils/files.dart';
import 'package:drawing_app/utils/get_image_dimensions.dart';
import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:screenshot/screenshot.dart';

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
  String selectedFileId = "";
  XFile? croppedImage;

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
  Rect? currentCropRect;

  List<NamedColorFilter> defaultFilters = defaultColorFilters;

  Uint8List? selectedFileData;

  bool firstTimeRan = false;

  ScreenshotController screenshotController = ScreenshotController();
  TransformationController interactiveViewerController = TransformationController();

  void setSelectedFileVars(XFile? file, bool resetCropped) async {
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
      selectedFileId = imageData.id;
      currentCropRect = imageData.cropRect;
    });
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (selectedFile != null) {
      return Screenshot(
        controller: screenshotController,
        child: InteractiveViewer(
          transformationController: interactiveViewerController,
          clipBehavior: Clip.none,
          boundaryMargin: const EdgeInsets.all(42.0),
          minScale: 0.1,
          maxScale: 5.0,
          child: EditedImage(
              cropRect: currentCropRect,
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
        setSelectedFileVars(response.files?[0], true);
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
      ImageData loadedImageData = await getSavedImageData(args.fileId);
      setSelectedFileVars(XFile(args.filePath), true);
      setImageDataVars(loadedImageData);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!firstTimeRan) {
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
        // backgroundColor: colorScheme.inversePrimary,
        title: Text(selectedFileName),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Center(child: _previewImages()),
        ),
      ),
      floatingActionButton: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FloatingActionButton.small(
              onPressed: () {
                interactiveViewerController.value = Matrix4.identity();
                screenshotController.capture().then((Uint8List? image) {
                  if (image != null && context.mounted) {
                    showExportImagePopup(context, image, selectedFileName);
                  }
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error.toString()),
                  ));
                });
              },
              heroTag: "export",
              tooltip: 'Export image with edits',
              child: const Icon(Icons.download),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () {
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
                            lastModified: DateTime.now(),
                            cropRect: currentCropRect,
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
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  if (context.mounted) {
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
                      setState(() {
                        selectedFileName = fileName;
                      });
                    }
                  }
                });
              },
              heroTag: "save",
              tooltip: 'Save image & edits',
              child: const Icon(Icons.save),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () async {
                Uint8List imageData = (await getImageData())!;
                if (context.mounted) {
                  showCropImagePopup(context, currentCropRect, imageData,
                      (Uint8List croppedImageData, Rect newCropRect) async {
                    setState(() {
                      currentCropRect = newCropRect;
                    });
                    await saveImageData(
                        selectedFileName,
                        selectedFileId,
                        ImageData(
                            lastModified: DateTime.now(),
                            cropRect: newCropRect,
                            name: selectedFileName,
                            id: selectedFileId,
                            colorFilter: selectedFilter,
                            gridOptions: GridOptions(
                                originalSize: await calculateImageDimensionFromData(croppedImageData),
                                rows: gridRows,
                                columns: gridColumns,
                                gridColor: gridLineColor,
                                gridLineWidth: gridLineWidth,
                                gridShowing: showGrid)));
                  });
                }
              },
              heroTag: "crop",
              tooltip: 'Crop image',
              child: const Icon(Icons.crop),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () {
                showImageFiltersPopup(context, selectedFilter, (filter) {
                  setState(() {
                    selectedFilter = filter;
                  });
                });
              },
              tooltip: 'Apply color filters',
              child: const Icon(Icons.palette),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () {
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
                });
              },
              heroTag: "grid",
              tooltip: 'Add grid lines',
              child: const Icon(Icons.grid_3x3),
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
