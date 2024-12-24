import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GridOverImage extends StatefulWidget {
  final XFile image;
  final Size originalSize;
  // final double width;
  // final double height;
  final int rows;
  final int columns;
  final Color gridColor;
  final double gridLineWidth;

  const GridOverImage({
    super.key,
    required this.image,
    required this.originalSize,
    // required this.width,
    // required this.height,
    required this.rows,
    required this.columns,
    this.gridColor = Colors.grey,
    this.gridLineWidth = 1.0,
  });

  @override
  State<GridOverImage> createState() => _GridOverImageState();
}

class _GridOverImageState extends State<GridOverImage> {
  Size? actualImageSize;
  bool _imageLoaded = false;

  Future<void> _getImageSize(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    print("width ${renderBox.size.width.toString()}");
    print("height ${(renderBox.size.height).toString()}");

    if (renderBox.size == actualImageSize) {
      return;
    } else {
      setState(() {
        actualImageSize = renderBox.size;
        _imageLoaded = true;
      });
    }
  }

  Widget imageFrameBuilder(BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      // Image loaded synchronously
      print('Image loaded synchronously');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else if (frame != null) {
      // Image loaded asynchronously, and a frame is available
      print('Image frame loaded');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getImageSize(context);
      });
    } else {
      // Image is still loading
      print('Image still loading');
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.originalSize.aspectRatio,
      child: Stack(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              return kIsWeb
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
                          print('Image loaded synchronously');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _getImageSize(context);
                          });
                        } else if (frame != null) {
                          // Image loaded asynchronously, and a frame is available
                          print('Image frame loaded');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _getImageSize(context);
                          });
                        } else {
                          // Image is still loading
                          print('Image still loading');
                        }
                        return child;
                      },
                    );
            }),
          ),
          if (actualImageSize != null)
            Positioned.fill(
                child: gridLines(actualImageSize!.width, actualImageSize!.height, widget.rows, widget.columns,
                    widget.gridColor, widget.gridLineWidth))
        ],
      ),
    );
  }
}

Widget gridLines(final double width, final double height, final int rows, final int columns, final Color gridColor,
    final double gridLineWidth) {
  return SizedBox(
      width: width,
      height: height,
      child: GridView.count(
          childAspectRatio: ((width) / columns) / ((height) / rows),
          primary: false,
          padding: const EdgeInsets.all(0),
          crossAxisCount: columns,
          children: List.generate(rows * columns, (int index) {
            return SizedBox(
              width: ((width - columns * gridLineWidth) / columns),
              height: ((height - rows * gridLineWidth) / rows),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: gridColor, width: gridLineWidth / 2)),
                // padding: const EdgeInsets.all(8),
                // color: Colors.teal[100],
              ),
            );
          }).toList()));
}
