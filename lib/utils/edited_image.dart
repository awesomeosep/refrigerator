import 'dart:io';

import 'package:drawing_app/edit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
}

class EditedImage extends StatefulWidget {
  final XFile image;
  final GridOptions gridOptions;
  final NamedColorFilter? filter;

  const EditedImage({
    super.key,
    required this.image,
    required this.gridOptions,
    required this.filter,
  });

  @override
  State<EditedImage> createState() => _EditedImageState();
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
        // _imageLoaded = true;
      });
    }
  }

  Widget imageFrameBuilder(BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      // Image loaded synchronously
      // print('Image loaded synchronously');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else if (frame != null) {
      // Image loaded asynchronously, and a frame is available
      // print('Image frame loaded');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else {
      // Image is still loading
      // print('Image still loading');
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
              return ColorFiltered(
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
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              // Image loaded synchronously
                              // print('Image loaded synchronously');
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _getImageSize(context);
                              });
                            } else if (frame != null) {
                              // Image loaded asynchronously, and a frame is available
                              // print('Image frame loaded');
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _getImageSize(context);
                              });
                            } else {
                              // Image is still loading
                              // print('Image still loading');
                            }
                            return child;
                          },
                        ));
            }),
          ),
          if (actualImageSize != null && widget.gridOptions.gridShowing)
            Positioned.fill(child: gridLines(actualImageSize!.width, actualImageSize!.height, widget.gridOptions))
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
