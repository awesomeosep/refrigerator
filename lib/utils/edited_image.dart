import 'dart:io';

import 'package:drawing_app/edit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class GridOptions {
  final Size originalSize;
  final int rows;
  final int columns;
  final Color gridColor;
  final double gridLineWidth;
  final bool gridShowing;

  const GridOptions({
    required this.originalSize,
    required this.rows,
    required this.columns,
    this.gridColor = Colors.red,
    this.gridLineWidth = 1.0,
    this.gridShowing = false,
  });

  Map toJson() {
    return {
      "originalWidth": originalSize.width.toString(),
      "originalHeight": originalSize.width.toString(),
      "rows": rows.toString(),
      "columns": columns.toString(),
      "gridColor": gridColor.toHexString(),
      "lineWidth": gridLineWidth.toString(),
      "gridShowing": gridShowing.toString(),
    };
  }

  static GridOptions fromJson(jsonObject) {
    return GridOptions(
        originalSize: Size(double.parse(jsonObject["originalWidth"].toString()),
            double.parse(jsonObject["originalHeight"].toString())),
        rows: int.parse(jsonObject["rows"].toString()),
        columns: int.parse(jsonObject["columns"].toString()),
        gridColor: Color(int.parse("0x${jsonObject["gridColor"]}")),
        gridLineWidth: double.parse(jsonObject["lineWidth"]),
        gridShowing: bool.parse(jsonObject["gridShowing"]));
  }
}

class ImageData {
  DateTime lastModified;
  Rect? cropRect;
  String? colorFilter;
  GridOptions gridOptions;
  String name;
  String id;

  ImageData(
      {required this.lastModified,
      required this.cropRect,
      required this.colorFilter,
      required this.gridOptions,
      required this.name,
      required this.id});

  Map toJson() {
    Map finalObject = {
      "lastModified": lastModified.toIso8601String(),
      "cropRect": [cropRect!.left, cropRect!.top, cropRect!.right, cropRect!.bottom],
      "gridOptions": gridOptions.toJson(),
      "colorFilter": colorFilter,
      "name": name,
      "id": id
    };
    return finalObject;
  }

  static ImageData fromJson(jsonObject) {
    return ImageData(
        lastModified: jsonObject["lastModified"] != null ? DateTime.parse(jsonObject["lastModified"]) : DateTime(2000, 1, 1, 1),
        cropRect: jsonObject["cropRect"] != null
            ? Rect.fromLTRB(jsonObject["cropRect"][0], jsonObject["cropRect"][1], jsonObject["cropRect"][2],
                jsonObject["cropRect"][3])
            : null,
        colorFilter: jsonObject["colorFilter"],
        gridOptions: GridOptions.fromJson(jsonObject["gridOptions"]),
        name: jsonObject["name"],
        id: jsonObject["id"]);
  }
}

class EditedImage extends StatefulWidget {
  final XFile image;
  final GridOptions gridOptions;
  final NamedColorFilter? filter;
  final Rect? cropRect;

  const EditedImage({
    super.key,
    required this.cropRect,
    required this.image,
    required this.gridOptions,
    required this.filter,
  });

  @override
  State<EditedImage> createState() => _EditedImageState();
}

class MyRectClipper extends CustomClipper<Rect> {
  final double left;
  final double top;
  final double right;
  final double bottom;

  MyRectClipper({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper != this;
  }
}

class _EditedImageState extends State<EditedImage> {
  Size? actualImageSize;
  // bool _imageLoaded = false;

  Future<void> _getImageSize(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    // print("width ${renderBox.size.width.toString()}");
    // print("height ${(renderBox.size.height).toString()}");

    if (renderBox.size == actualImageSize) {
      return;
    } else {
      setState(() {
        actualImageSize = renderBox.size;
      });
    }
  }

  Widget imageFrameBuilder(BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      // Image loaded synchronously
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else if (frame != null) {
      // Image loaded asynchronously, and a frame is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else {
      // Image is still loading
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.gridOptions.originalSize.aspectRatio,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                child: ClipRect(
                    clipper: actualImageSize == null
                        ? MyRectClipper(left: 0, top: 0, right: 0, bottom: 0)
                        : (widget.cropRect == null
                            ? MyRectClipper(
                                left: 0, top: 0, right: actualImageSize!.width * 1, bottom: actualImageSize!.height * 1)
                            : MyRectClipper(
                                left: actualImageSize!.width * widget.cropRect!.left,
                                top: actualImageSize!.height * widget.cropRect!.top,
                                right: actualImageSize!.width * widget.cropRect!.right,
                                bottom: actualImageSize!.height * widget.cropRect!.bottom)),
                    child: ColorFiltered(
                        colorFilter: (widget.filter == null)
                            ? const ColorFilter.matrix([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0])
                            : widget.filter!.filter,
                        child: kIsWeb
                            ? Image.network(fit: BoxFit.contain, widget.image.path, frameBuilder: imageFrameBuilder)
                            : Image.file(
                                File(widget.image.path),
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return const Center(child: Text('This image type is not supported'));
                                },
                                frameBuilder: imageFrameBuilder,
                              ))),
              );
            }),
          ),
          if (actualImageSize != null && widget.cropRect != null && widget.gridOptions.gridShowing)
            Positioned.fill(
                child: gridLines(actualImageSize!.width * (widget.cropRect!.right - widget.cropRect!.left),
                    actualImageSize!.height * (widget.cropRect!.bottom - widget.cropRect!.top), widget.gridOptions))
        ],
      ),
    );
  }
}

Widget gridLines(final double width, final double height, final GridOptions gridOptions) {
  return SizedBox(
      width: width,
      height: height,
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridOptions.columns,
            childAspectRatio: ((width) / gridOptions.columns) / ((height) / gridOptions.rows),
          ),
          itemCount: gridOptions.rows * gridOptions.columns,
          primary: false,
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return SizedBox(
              width: ((width - gridOptions.columns * gridOptions.gridLineWidth) / gridOptions.columns),
              height: ((height - gridOptions.rows * gridOptions.gridLineWidth) / gridOptions.rows),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: gridOptions.gridColor, width: gridOptions.gridLineWidth / 2)),
              ),
            );
          }));
}
