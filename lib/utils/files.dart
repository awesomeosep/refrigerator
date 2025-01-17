import 'dart:convert';
import 'dart:io';

import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get getLocalPath async {
  // List<Directory>? foundDirectories = await getExternalStorageDirectories(type: StorageDirectory.documents);
  // Directory directory;
  // if (foundDirectories?.isNotEmpty == true) {
  // directory = Directory("/storage/emulated/0/Documents");
  // } else {
  // directory = await getApplicationDocumentsDirectory();
  // }
  Directory directory;
  if (Platform.isWindows) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = (await getExternalStorageDirectory())!;
  }
  return directory.path;
}

Future<String> get getImagesDirectory async {
  String localPath = await getLocalPath;
  return "$localPath/_drawing_app_data/saved_images";
}

Future<String> get getImageDataDirectory async {
  String localPath = await getLocalPath;
  return "$localPath/_drawing_app_data/image_data";
}

Future<String> get getDownloadsPath async {
  Directory? downloadsDir;
  if (Platform.isWindows) {
    downloadsDir = await getDownloadsDirectory();
  } else {
    downloadsDir = Directory("/storage/emulated/0/Download");
  }
  if (downloadsDir != null) {
    return downloadsDir.path;
  } else {
    return "";
  }
}

Future<void> checkForSavedImagesFolder() async {
  String imagesDirectoryPath = await getImagesDirectory;
  bool checkPathExistence = await Directory(imagesDirectoryPath).exists();
  if (!checkPathExistence) {
    // print("creating new images directory");
    await Directory(imagesDirectoryPath).create(recursive: true);
  } else {
    // print("images directory already exists");
  }
  String dataDirectoryPath = await getImageDataDirectory;
  bool checkPathExistence2 = await Directory(dataDirectoryPath).exists();
  if (!checkPathExistence2) {
    // print("creating new data directory");
    await Directory(dataDirectoryPath).create(recursive: true);
  } else {
    // print("data directory already exists");
  }
}

Future<List<FileSystemEntity>> getAllSavedImages() async {
  String imagesDirectoryPath = await getImagesDirectory;
  final dir = Directory(imagesDirectoryPath);
  final List<FileSystemEntity> entities = await dir.list().toList();
  return entities;
}

Future<String> saveImage(XFile file, String newName, String fileExtension) async {
  String imagesDirectoryPath = await getImagesDirectory;
  String imagePath = "$imagesDirectoryPath/$newName$fileExtension";
  file.saveTo(imagePath);
  return imagePath;
}

Future<String> saveImageFromData(Uint8List imageData, String newName, String fileExtension) async {
  String imagesDirectoryPath = await getImagesDirectory;
  String imagePath = "$imagesDirectoryPath/$newName$fileExtension";
  File(imagePath).writeAsBytes(imageData);
  return imagePath;
  // return "$imagesDirectoryPath/$newName$fileExtension";
}

Future<File> saveImageData(String imageName, String fileId, ImageData imageCustomizations) async {
  String imageDataDirectoryPath = await getImageDataDirectory;
  Map dataObject = imageCustomizations.toJson();
  String dataString = json.encode(dataObject);
  File textFile = await File("$imageDataDirectoryPath/$fileId.txt").writeAsString(dataString);
  return textFile;
}

Future<void> deleteFile(String fileId, String imageFileExtension) async {
  String imageDataDirectoryPath = await getImageDataDirectory;
  String imagesDirectoryPath = await getImagesDirectory;
  await File("$imagesDirectoryPath/$fileId$imageFileExtension").delete();
  await File("$imageDataDirectoryPath/$fileId.txt").delete();
}

Future<String> getSavedImagePathFromId(String fileId) async {
  String imageDataDirectoryPath = await getImageDataDirectory;
  return "$imageDataDirectoryPath/$fileId.txt";
}

Future<ImageData> getSavedImageData(String fileId) async {
  String imageDataDirectoryPath = await getImageDataDirectory;
  String stringData = await File("$imageDataDirectoryPath/$fileId.txt").readAsString();
  ImageData loadedImageData = ImageData.fromJson(json.decode(stringData));
  return loadedImageData;
}

Future<String> dataPathFromId(String fileId) async {
  String imageDataDirectoryPath = await getImageDataDirectory;
  return "$imageDataDirectoryPath/$fileId.txt";
}

Future<String> exportImageFromData(Uint8List imageData, String fileName) async {
  String downloadsPath = await getDownloadsPath;
  File exportFile = await File('$downloadsPath/$fileName.jpg').writeAsBytes(imageData);
  return exportFile.path;
}
