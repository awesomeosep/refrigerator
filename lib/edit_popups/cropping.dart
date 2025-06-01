import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';

Future<void> showCropImagePopup(BuildContext context, Rect? initialCropRect, Uint8List imageData, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final cropController = CropController(
        aspectRatio: null,
        defaultCrop: initialCropRect ?? const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
      );

      return AlertDialog(
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Column(
              children: [
                Expanded(
                    child: CropImage(
                  minimumImageSize: 75,
                  image: Image.memory(imageData),
                  controller: cropController,
                )),
                const SizedBox(height: 16),
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    const Text("Aspect Ratio:"),
                    FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                cropController.aspectRatio == null ? Colors.indigo : Colors.indigo[200])),
                        onPressed: () {
                          setState(() {
                            cropController.aspectRatio = null;
                          });
                        },
                        child: const Text("Free")),
                    FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                cropController.aspectRatio == (16 / 9) ? Colors.indigo : Colors.indigo[200])),
                        onPressed: () {
                          setState(() {
                            cropController.aspectRatio = (16 / 9);
                          });
                        },
                        child: const Text("16:9")),
                    FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                cropController.aspectRatio == (3 / 2) ? Colors.indigo : Colors.indigo[200])),
                        onPressed: () {
                          setState(() {
                            cropController.aspectRatio = (3 / 2);
                          });
                        },
                        child: const Text("3:2")),
                    FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                cropController.aspectRatio == 1 ? Colors.indigo : Colors.indigo[200])),
                        onPressed: () {
                          setState(() {
                            cropController.aspectRatio = 1;
                          });
                        },
                        child: const Text("1:1"))
                  ],
                ),
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    const Text("Horizontal Alignment:"),
                    IconButton(
                      icon: const Icon(Icons.align_horizontal_left),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(0, cropController.crop.top,
                              cropController.crop.right - cropController.crop.left, cropController.crop.bottom);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.align_horizontal_center),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(
                              (1 - (cropController.crop.right - cropController.crop.left)) / 2,
                              cropController.crop.top,
                              1 - (1 - (cropController.crop.right - cropController.crop.left)) / 2,
                              cropController.crop.bottom);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.align_horizontal_right),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(
                              cropController.crop.left + (1 - cropController.crop.right),
                              cropController.crop.top,
                              1,
                              cropController.crop.bottom);
                        });
                      },
                    ),
                  ],
                ),
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    const Text("Vertical Alignment:"),
                    IconButton(
                      icon: const Icon(Icons.align_vertical_top),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(cropController.crop.left, 0, cropController.crop.right,
                              cropController.crop.bottom - cropController.crop.top);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.align_vertical_center),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(
                              cropController.crop.left,
                              (1 - (cropController.crop.bottom - cropController.crop.top)) / 2,
                              cropController.crop.right,
                              1 - (1 - (cropController.crop.bottom - cropController.crop.top)) / 2);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.align_vertical_bottom),
                      onPressed: () {
                        setState(() {
                          cropController.crop = Rect.fromLTRB(cropController.crop.left,
                              1 - (cropController.crop.bottom - cropController.crop.top), cropController.crop.right, 1);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () async {
              ui.Image croppedImage = await cropController.croppedBitmap();
              ByteData? data = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
              Uint8List bytes = data!.buffer.asUint8List();
              onUpdate(bytes, cropController.crop);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
