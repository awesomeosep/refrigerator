import 'package:drawing_app/utils/files.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showDeleteImagePopup(BuildContext context, String filePath) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Are you sure you want to delete this file?"),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Text("File name: ${XFile(filePath).name}");
        }),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Delete'),
            onPressed: () {
              deleteFile(filePath);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
