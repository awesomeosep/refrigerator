import 'package:drawing_app/utils/files.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> showExportImagePopup(BuildContext context, Uint8List exportedImageData, String fileName) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      TextEditingController fileNameController = TextEditingController(text: fileName);

      return AlertDialog(
        title: const Text('Export Image'),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: ListBody(children: <Widget>[
              const Text("Export the image with your edits to your downloads folder."),
              const SizedBox(height: 16),
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'File Name',
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
                child: Image.memory(exportedImageData),
              ),
            ]),
          );
        }),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Export Image'),
            onPressed: () {
              exportImageFromData(exportedImageData, fileNameController.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Exported to downloads"),
              ));
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
