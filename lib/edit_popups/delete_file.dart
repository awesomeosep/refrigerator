import 'package:drawing_app/utils/files.dart';
import 'package:flutter/material.dart';

Future<void> showDeleteImagePopup(BuildContext context, String fileId, String imageFileExtension) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Are you sure you want to delete this file?"),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Text("File name: $fileId");
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
              deleteFile(fileId, imageFileExtension);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
