import 'dart:io';

import 'package:flutter/material.dart';

Future<Size> getImageDimensions(File imageFile) async {
  var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
}
