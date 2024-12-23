import 'dart:io';

import 'package:flutter/material.dart';

Future<Size> getImageDimensions(File imageFile) async {
  var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  // print(decodedImage.width);
  // print(decodedImage.height);
  return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
}
