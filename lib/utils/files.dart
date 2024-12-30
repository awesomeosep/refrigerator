import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get getLocalPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> get getImagesDirectory async {
  String localPath = await getLocalPath;
  return "$localPath/_drawing_app_data/saved_images";
}

Future<void> checkForSavedImagesFolder() async {
  String imagesDirectoryPath = await getImagesDirectory;
  bool checkPathExistence = await Directory(imagesDirectoryPath).exists();
  if (!checkPathExistence) {
    print("creating new directory");
    await Directory(imagesDirectoryPath).create(recursive: true);
  } else {
    print("directory already exists");
    return;
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
  file.saveTo("$imagesDirectoryPath/$newName$fileExtension");
  return "$imagesDirectoryPath/$newName$fileExtension";
}

Future<void> deleteFile(String filePath) async {
  await File(filePath).delete();
}
