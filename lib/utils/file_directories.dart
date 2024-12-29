import 'package:path_provider/path_provider.dart';

Future<String> get getLocalPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> get getImagesDirectory async {
  String localPath = await getLocalPath;
  return "$localPath/_drawing_app_data/images";
}
