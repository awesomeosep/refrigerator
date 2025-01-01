import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

Future<Size> getImageDimensions(File imageFile) async {
  var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
}

Future<Size> calculateImageDimension(File imageFile) {
  Completer<Size> completer = Completer();
  Image image = Image.file(imageFile);
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}
