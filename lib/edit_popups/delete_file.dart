import 'package:drawing_app/utils/files.dart';
import 'package:flutter/material.dart';

Future<void> showDeleteImagePopup(
    BuildContext context, String fileId, String fileName, String imageFileExtension) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      bool isLoading = false;
      final colorScheme = Theme.of(context).colorScheme;

      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete this file?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File id: $fileId"),
              Text("File name: $fileName"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: colorScheme.inversePrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Container(),
                  isLoading ? const SizedBox(width: 16) : Container(),
                  const Text('Delete'),
                ],
              ),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                deleteFile(fileId, imageFileExtension);
                setState(() {
                  isLoading = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    },
  );
}
